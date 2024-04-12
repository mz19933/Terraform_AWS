<h1 align="center">
 <a href="https://www.terraform.io/">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://upload.wikimedia.org/wikipedia/commons/0/04/Terraform_Logo.svg"/>
    <img width="400" src="https://upload.wikimedia.org/wikipedia/commons/0/04/Terraform_Logo.svg"/>
 </a>
</h1>
    
## <p align="center"><strong>🔮 Documentation for Terraform on AWS. 🔮 </strong></p>

### Objective 🎯 
This guide will present a simple project goal - using TF to Deploy an AWS service, and the necessary components for achieving it.

In AWS, using Terraform, we will do the following:
- Create vpc
- Create internet gateway
- Create custom route table
- Create a subnet
- Associate subnet with route table
- Create Secuirty group
- Create a network interface
- Assign an elastic ip to the network interface
- Create Ubuntu server and install/enable apache2 as web server

### Get started  🚀
Download and setup Terraform on Ubuntu/Windows.

(Since I'm using both linux and win machines for my projects, I want the flexibility of being able to use it in both environments.)

### How to install on Windows 10 -
Run PowerShell as an admin, to have the permissions to edit the environment variables.



```bash
# Download Terraform, specifically for this example I'm using 1.7.5 and D:\Projects\Terraform as a project path folder
wget -O D:\Projects\Terraform\terraform_1.7.5_windows_amd64.zip https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_windows_amd64.zip

# Unzip
Get-ChildItem 'D:\Projects\Terraform\terraform_1.7.5_windows_amd64.zip' -Filter *.zip | Expand-Archive -DestinationPath 'D:\Projects\Terraform\' -Force

# Define the path to the Terraform executable
$terraformPath = "D:\Projects\Terraform"

# Add the Terraform directory to the system PATH environment variable
$currentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = $currentPath + ";$terraformPath"
[Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

# refresh current powershell session for the changes to take affect
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

# To see if it worked, try getting the version
terraform -v

output-
"Terraform v1.7.5
on windows_amd64"
```

### How to install on Ubuntu 22.04 -

```bash
# Download Terraform, specifically for this example I'm using 1.7.5 and /data/terraform/ as a project path folder
wget -O /data/terraform/terraform_1.7.5_linux_amd64.zip https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip

# Unzip
unzip terraform_1.7.5_linux_amd64.zip

# Move Terraform exe to /usr/local/bin/ to be globally accessible
sudo mv terraform /usr/local/bin/terraform

# To see if it worked, try using it from home directory
cd ~
terraform -v

output-
"Terraform v1.7.5
on linux_amd64"
```

### AWS Console setup 💻
In the upper right corner, select your preferable region (I'm using eu-central-1, as shown in picture below)
![image](https://github.com/mz19933/Terraform_AWS/assets/61427854/b8d27fdf-f3db-4b8d-a515-b189d59b3792)

### Authentication 🔐
**Get your Access key ID and Secret Access key from your AWS profile**

Profile name -> security credentials -> Access keys -> Create access key -> Download .csv file \ copy the keys -> Done

We will then create an AWS credentials file, to store our keys securely AND NOT HARD CODE IT IN OUR TERRAFORM FILE.

AWS credentials stored in ~/.aws/credentials on Unix-like systems or %USERPROFILE%\.aws\credentials on Windows.

**Set up a Key Pairs(is needed for later steps)**

Console home -> All Services -> EC2

![image](https://github.com/mz19933/Terraform_AWS/assets/61427854/e20c0620-f12f-4bec-86ee-8b7aef4f1547)

NetWork & Secuirty -> Key Pairs

![image](https://github.com/mz19933/Terraform_AWS/assets/61427854/97d533db-02a6-440d-ab5e-1ce50376f193)

Create a Key

![image](https://github.com/mz19933/Terraform_AWS/assets/61427854/cdc47fe4-fb6e-455a-9dd2-16ae87bc6ded)

###   Projects steps🛠️

1) **Create vpc**
- [Terraform docs for vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
```bash
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags ={
    Name = "production"
  }
}
```

2) **Create VPC Internet Gateway**
- [Terraform docs for VPC Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)
```bash
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}
```

3) **Create custom route table**
- [Terraform docs for route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)
```bash
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
```

4) **Create a subnet**
- [Terraform docs for subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)
```bash
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1"

  tags = {
    Name = "Prod-subnet"
  }
}
```

5) **Associate subnet with route table**
- [Terraform docs for association between a route table and a subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)
```bash
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.prod-route-table.id
}
```

6) Create Secuirty group to allow port 22,80,443
- [Terraform docs for Secuirty group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)
```bash
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
```

- 
7) Create a network interface with an ip in the subnet(10.0.1.0/24) that was created in step 4
  - [Terraform docs for network interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface)
```bash
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}
```


8) Assign an elastic ip to the network interface created in step 7
- [Terraform docs for an elastic ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)
```bash
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
}
```

9) Create Ubuntu server and install/enable apache2 as web server
- [Terraform docs for AWS instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
```bash
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
```

## Resources and references

- [Terraform Course](https://youtu.be/SLB_c_ayRMo?si=d0ZD4EN033mmUCnG) - A great course for beginners, on which most of this project is based on.
- [Terraform Site](https://github.com/aimeos/aimeos-typo3#readme) - The official Terraform site.
- [Terraform docs](https://developer.hashicorp.com/terraform/docs) - The official Terraform docs.
