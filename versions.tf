terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}

# Configure the AWS Provider
# IMPORTANT: Ensure your availability_zones in terraform.tfvars match this region!
# You can set the region via AWS_REGION environment variable or AWS CLI config
# or uncomment and configure it here explicitly
provider "aws" {
  # region = "us-west-2"  # Uncomment to explicitly set region
}
