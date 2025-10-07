variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "vpc_state_bucket" {
  description = "S3 bucket where VPC state is stored"
  type        = string
  default     = "my-terraform-states-us-east-1"
}

variable "vpc_state_key" {
  description = "S3 key of the VPC state file"
  type        = string
  default     = "vpc/terraform.tfstate"
}

variable "vpc_state_region" {
  description = "Region of the S3 bucket storing VPC state"
  type        = string
  default     = "us-east-1"
}
