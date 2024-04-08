# Terraform doesn't support having duplicate configurations across files within the same module. Since both test.tf and main.tf are in the same directory and represent the same module, Terraform sees them as a single configuration.
# With this separation, main.tf contains the common configurations such as providers, data sources, and outputs, while test.tf can include specific configurations or resources related to tests. 

# Terraform itself doesn't have a built-in command to directly "ping" AWS to check if your credentials are working.
# One common approach is to try to describe something that exists in AWS regardless of whether you've created it yourself or not, like a listing of AWS regions.
data "aws_regions" "current" {}

output "available_regions" {
  value = data.aws_regions.current.names
}