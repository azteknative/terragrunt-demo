# Include the root configuration
include "root" {
  path = find_in_parent_folders()
}

# Specify the Terraform module source
terraform {
  source = "../../../../modules/vpc"
}

# Override inputs for production environment
inputs = {
  environment = "prod"
  
  # VPC Configuration - different CIDR to avoid conflicts
  vpc_cidr = "10.1.0.0/16"
  
  # Subnets - 3 AZs for high availability
  availability_zones = [
    "eu-west-2a",
    "eu-west-2b", 
    "eu-west-2c"
  ]
  
  public_subnet_cidrs = [
    "10.1.1.0/24",
    "10.1.2.0/24",
    "10.1.3.0/24"
  ]
  
  private_subnet_cidrs = [
    "10.1.10.0/24",
    "10.1.20.0/24",
    "10.1.30.0/24"
  ]
  
  # Production configuration - multiple NAT gateways for redundancy
  enable_nat_gateway     = true
  single_nat_gateway     = false  # Multi-AZ NAT gateways for production
  
  # VPC Flow Logs
  enable_vpc_flow_logs        = true
  flow_logs_retention_days    = 30  # Longer retention for prod
  
  # DNS Configuration
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # Additional tags
  additional_tags = {
    CostCenter = "production"
    Owner      = "platform-team"
    Backup     = "required"
    Monitoring = "enhanced"
  }
} 