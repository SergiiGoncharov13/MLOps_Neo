locals {
  cluster_name     = "eks-cluster"
  env              = "dev"
  vpc_state_bucket = "my-terraform-states-us-east-1"
  vpc_state_key    = "vpc/terraform.tfstate"
  vpc_state_region = "us-east-1"
}
