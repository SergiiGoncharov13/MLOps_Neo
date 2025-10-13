variable "namespace" {
  default = "infra-tools"
}

variable "argocd_version" {
  default = "7.4.4"
}

variable "cluster_name" {
  description = "EKS cluster name to connect to"
  type        = string
  default     = "eks-cluster"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
