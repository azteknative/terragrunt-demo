# Include the root configuration
include "root" {
  path = find_in_parent_folders()
}

# Specify the Terraform module source
terraform {
  source = "../../../../modules/vpc"
}

# Override inputs for development environment
inputs = {
  environment = "dev"
  
  # VPC Configuration
  vpc_cidr = "10.0.0.0/16"
  
  # Subnets - 3 AZs for high availability
  availability_zones = [
    "eu-west-2a",
    "eu-west-2b", 
    "eu-west-2c"
  ]
  
  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
  
  private_subnet_cidrs = [
    "10.0.10.0/24",
    "10.0.20.0/24",
    "10.0.30.0/24"
  ]
  
  # Cost optimization for dev environment
  enable_nat_gateway     = true
  single_nat_gateway     = true  # Use single NAT gateway to save costs
  
  # VPC Flow Logs
  enable_vpc_flow_logs        = true
  flow_logs_retention_days    = 7  # Short retention for dev
  
  # DNS Configuration
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # Additional tags
  additional_tags = {
    CostCenter = "development"
    Owner      = "platform-team"
  }
} 