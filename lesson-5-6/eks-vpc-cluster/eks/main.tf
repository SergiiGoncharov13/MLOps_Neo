data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.vpc_state_bucket
    key    = var.vpc_state_key
    region = var.vpc_state_region
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                  = var.cluster_name
  cluster_version               = "1.30"
  cluster_endpoint_public_access = true

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets


  eks_managed_node_groups = {
    cpu = {
      instance_types = ["t3.small"]  
      desired_size   = 2
      min_size       = 1
      max_size       = 2
    }
  }


  enable_cluster_creator_admin_permissions = true

  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}
