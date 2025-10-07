# AWS VPC + EKS Terraform Infrastructure

## Requirements
- AWS CLI 
- Terraform
- kubectl

## Run

``` bash
cd /eks-vpc-cluster/vpc
terraform init -reconfigure
terraform validate
terraform plan
terraform apply
cd ../eks
terraform init -reconfigure
terraform validate
terraform plan
terraform apply
```

## Check 

``` bash
aws eks --region us-east-1 update-kubeconfig --name eks-cluster
kubectl get nodes
```

## Destroy

``` bash
cd /eks-vpc-cluster/vpc
terraform destroy
cd ../eks
terraform destroy
```
