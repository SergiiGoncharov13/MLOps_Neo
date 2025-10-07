module "vpc" {
  source = "./vpc"

  vpc_name          = "eks-vpc"
  vpc_cidr          = "10.0.0.0/16"
  availability_zones = ["us-east-1a","us-east-1b","us-east-1c"]
  private_subnets   = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  public_subnets    = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]
  env               = local.env
}

module "eks" {
  source = "./eks"

  cluster_name     = local.cluster_name
  env              = local.env
  vpc_state_bucket = local.vpc_state_bucket
  vpc_state_key    = local.vpc_state_key
  vpc_state_region = local.vpc_state_region
}
