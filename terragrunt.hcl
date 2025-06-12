# Root Terragrunt configuration
# This file contains common configurations that will be inherited by all child configurations

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "terragrunt-demo-tfstate-${get_env("AWS_ACCOUNT_ID", "unknown")}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terragrunt-demo-locks"
    
    # Enable versioning and lifecycle policies
    s3_bucket_tags = {
      Name        = "Terragrunt State Bucket"
      Environment = "shared"
      ManagedBy   = "Terragrunt"
    }
    
    dynamodb_table_tags = {
      Name        = "Terragrunt Lock Table"
      Environment = "shared"
      ManagedBy   = "Terragrunt"
    }
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terragrunt"
    }
  }
}
EOF
}

# Configure common input variables
inputs = {
  project_name = "terragrunt-demo"
  aws_region   = "eu-west-2"
} 