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
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }
}

# Subnet

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  # If you try nad use "eu-cnetral-1" you will get an error "Error: creating EC2 Subnet: InvalidParameterValue: Value (eu-central-1) for parameter availabilityZone is invalid", so we use eu-central-1a
  availability_zone = "eu-central-1a"

  tags = {
    Name = "Prod-subnet"
  }
}

# Associate subnet with route table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}

# Secuirty group to allow port 22,80,443

resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  tags = {
    Name = "allow_web"
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # All protocols
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Network interface

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# Assign an elastic ip to the network interface

resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

# Ubuntu server + install/enable apach2 as web server

resource "aws_instance" "web-server-instance" {
  ami           = "ami-023adaba598e661ac"
  instance_type = "t2.micro"
  availability_zone = "eu-central-1a"
  key_name = "main-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 curl -y
                sudo systemctl start apache2
                # Create directory for website files
                sudo mkdir -p /var/www/html
                # Download HTML file from GitHub (This URL points directly to the raw content of a file)
                sudo curl -o /var/www/html/index.html https://raw.githubusercontent.com/mz19933/Terraform_AWS/main/HTML/index.html
                # Download CSS file from GitHub
                sudo curl -o /var/www/html/styles.css https://raw.githubusercontent.com/mz19933/Terraform_AWS/main/HTML/styles.css
                EOF
  tags = {
    Name = "web-server"
  }
}

/* 
# Include the self-made available_regions module
module "available_regions" {
  source = "./available_regions"
}

# Define output for the available_regions module
output "available_regions" {
  value = module.available_regions.available_regions
}
 */