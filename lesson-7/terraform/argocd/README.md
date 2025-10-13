## Requirements
- AWS CLI 
- Terraform
- kubectl
- AWS EKS

## Run

```bash
cd /terraform/argocd
terraform init
terraform apply
```

## Check 

``` bash
aws eks --region us-east-1 update-kubeconfig --name eks-cluster
kubectl get nodes
```

## Use MLFlow
[Go to GitHub repository](https://github.com/SergiiGoncharov13/goit-argo.git) and folow instruction in `README.md` file <br>
`https://github.com/SergiiGoncharov13/goit-argo.git`

## Destroy

``` bash
terraform destroy
```
