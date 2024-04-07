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
}