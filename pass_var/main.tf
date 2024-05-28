# Overall configuration for Terraform itself, from which source (public or private registry) and what version (5.0 or any later version in the 5.x series)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
  shared_credentials_files = ["C:\\Users\\micha\\.aws\\credentials"]
  profile = "default"
}

# VPC
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags ={
    Name = var.vpc_name
  }
}