<h1 align="center">
 <a href="https://www.terraform.io/">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="https://upload.wikimedia.org/wikipedia/commons/0/04/Terraform_Logo.svg"/>
    <img width="400" src="images/plandex-logo-dark-bg.png"/>
 </a>
</h1>
    
## <p align="center"><strong>🔮 Documentation for Terraform on AWS. 🔮 </strong></p>

This guide will present a simple project goal - using TF to Deploy an AWS service, and the steps necessary for achieving it.

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
```

### How to install on Ubuntu 22.04 -

