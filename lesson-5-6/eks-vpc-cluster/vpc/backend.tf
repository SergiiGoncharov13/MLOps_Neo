terraform {
  backend "s3" {
    bucket = "my-terraform-states-us-east-1"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}