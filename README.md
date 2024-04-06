# Documentation for using Terraform and AWS
# This guide will present a simple project goal - using TF to Deploy an aws service, and the steps necessary for achieving it.

Steps:
1) Download and setup Terraform Ubuntu/Windows -
# Since I'm using both linux and win machines for my projects, i want the flexibility of being able to use it in both environments.

In windows -
# Run PowerShell as admin, for editing the environment variables
# Download Terraform, specifically for this example i'm using 1.7.5 and and D:\Projects\Terraform as a path to my project folder
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

In linux -

