<h1 align="center">
 <a href="https://www.terraform.io/">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://upload.wikimedia.org/wikipedia/commons/0/04/Terraform_Logo.svg"/>
    <img width="400" src="https://upload.wikimedia.org/wikipedia/commons/0/04/Terraform_Logo.svg"/>
 </a>
</h1>
    
## <p align="center"><strong>🔮 Documentation for Terraform on AWS. 🔮 </strong></p>

This guide will present a simple project goal - using TF to Deploy an AWS service, and the necessary components for achieving it.

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
Get your Access key ID and Secret Access key from your AWS profile

Profile name -> security credentials -> Access keys -> Create access key -> Download .csv file \ copy the keys -> Done

We will then create an AWS credentials file, to store our keys securely AND NOT HARD CODED IN OUR TERRAFORM FILE.

AWS credentials stored in ~/.aws/credentials on Unix-like systems or %USERPROFILE%\.aws\credentials on Windows.

###   Terraform file breakdown🛠️

