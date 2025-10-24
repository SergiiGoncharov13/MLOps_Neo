# MLOps train automation

## Create archive
```bash
cd mlops-traine-automation/terraform/lambda
zip -j validate.zip validate.py
zip -j log_metrics.zip log_metrics.py
```
## Terraform
```bash
cd .. 
terraform init
terraform apply
```
save outputs

## Run stepfunction 
```bash
aws stepfunctions start-execution \
--state-machine-arn <STATE_MACHINE_ARN> \
--name "manual-$(date +%s)" \
--input '{"source":"manual","data":{"a":1}}'
```
or use AWS website

## env for GitLab
- AWS_ACCESS_KEY_ID 
- AWS_SECRET_ACCESS_KEY
- AWS_DEFAULT_REGION
- STATE_MACHINE_ARN

## Job calls
```bash
aws stepfunctions start-execution --state-machine-arn $STATE_MACHINE_ARN --name "train-$(date +%s)" --input '{"source":"gitlab-ci", "commit":"'$CI_COMMIT_SHORT_SHA'"}'
```

## json example
```json
{
"source": "gitlab-ci",
"commit": "abc123",
"data": {"feature_1": 0.5},
"metrics": {"initial": 0}
}
```
