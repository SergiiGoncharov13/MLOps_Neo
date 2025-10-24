terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "mlops_lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "sfn_role" {
  name = "mlops_sfn_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "sfn_invoke_lambda" {
  name        = "mlops_sfn_invoke_lambda"
  description = "Allow Step Functions to invoke Lambda functions and write logs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["lambda:InvokeFunction", "lambda:InvokeAsync"],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents","logs:CreateLogDelivery"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sfn_attach_policy" {
  role       = aws_iam_role.sfn_role.name
  policy_arn = aws_iam_policy.sfn_invoke_lambda.arn
}

resource "aws_lambda_function" "validate" {
  function_name    = "mlops_validate"
  filename         = "${path.module}/lambda/validate.zip"
  handler          = "validate.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_exec_role.arn
  timeout          = var.lambda_timeout
  source_code_hash = filebase64sha256("${path.module}/lambda/validate.zip")
}

resource "aws_lambda_function" "log_metrics" {
  function_name    = "mlops_log_metrics"
  filename         = "${path.module}/lambda/log_metrics.zip"
  handler          = "log_metrics.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_exec_role.arn
  timeout          = var.lambda_timeout
  source_code_hash = filebase64sha256("${path.module}/lambda/log_metrics.zip")
}

resource "aws_lambda_permission" "allow_sfn_validate" {
  statement_id  = "AllowExecutionFromStepFunctionsValidate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.validate.function_name
  principal     = "states.amazonaws.com"
}

resource "aws_lambda_permission" "allow_sfn_logmetrics" {
  statement_id  = "AllowExecutionFromStepFunctionsLogMetrics"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.log_metrics.function_name
  principal     = "states.amazonaws.com"
}

resource "aws_sfn_state_machine" "mlops_train_pipeline" {
  name     = "mlops-train-pipeline"
  role_arn = aws_iam_role.sfn_role.arn

  definition = jsonencode({
    Comment = "ML training pipeline: validate -> log_metrics",
    StartAt = "ValidateData",
    States = {
      ValidateData = {
        Type     = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = aws_lambda_function.validate.arn,
          Payload = { "Input.$" = "$" }
        },
        ResultPath = "$.validate_result",
        Next = "LogMetrics"
      },
      LogMetrics = {
        Type     = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = aws_lambda_function.log_metrics.arn,
          Payload = {
            "validate.$" = "$.validate_result",
            "Input.$" = "$"
          }
        },
        End = true
      }
    }
  })
}

resource "aws_iam_user" "gitlab_ci_user" {
  name = "gitlab-ci-user"
}

resource "aws_iam_access_key" "gitlab_ci_user_key" {
  user = aws_iam_user.gitlab_ci_user.name
}

resource "aws_iam_role" "gitlab_ci_role" {
  name = "mlops_gitlab_ci_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_user.gitlab_ci_user.arn
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "gitlab_ci_sfn_policy" {
  name   = "mlops_ci_sfn_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["states:StartExecution"],
        Resource = aws_sfn_state_machine.mlops_train_pipeline.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ci_attach" {
  role       = aws_iam_role.gitlab_ci_role.name
  policy_arn = aws_iam_policy.gitlab_ci_sfn_policy.arn
}

output "state_machine_arn" {
  value = aws_sfn_state_machine.mlops_train_pipeline.arn
}

output "validate_lambda_arn" {
  value = aws_lambda_function.validate.arn
}

output "log_metrics_lambda_arn" {
  value = aws_lambda_function.log_metrics.arn
}

output "gitlab_ci_user_access_key_id" {
  value = aws_iam_access_key.gitlab_ci_user_key.id
}

output "gitlab_ci_user_secret_access_key" {
  value     = aws_iam_access_key.gitlab_ci_user_key.secret
  sensitive = true
}

output "gitlab_ci_role_arn" {
  value = aws_iam_role.gitlab_ci_role.arn
}
