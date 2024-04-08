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
    Name = "production"
  }
}

# Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
}

# Custom route table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    # Defualt route, send all tarfic
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    # Same for IPv6, send all tarfic
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }
}

# Subnet

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1"

  tags = {
    Name = "Prod-subnet"
  }
}

# Include the self-made available_regions module
module "available_regions" {
  source = "./available_regions"
}

# Define output for the available_regions module
output "available_regions" {
  value = module.available_regions.available_regions
}