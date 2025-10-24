variable "aws_region" {
description = "AWS region"
type = string
default = "us-east-1"
}

variable "lambda_timeout" {
description = "Timeout for Lambda functions in seconds"
type = number
default = 60
}
