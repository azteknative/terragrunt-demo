# Include the root configuration
include "root" {
  path = find_in_parent_folders()
}

# Specify the Terraform module source
terraform {
  source = "../../../../modules/ecs-fargate"
}

# Dependency on VPC - this ensures proper ordering for create/destroy operations
dependency "vpc" {
  config_path = "../vpc"
  
  # Skip outputs during destroy to avoid dependency issues
  skip_outputs = true
  
  mock_outputs = {
    vpc_id              = "vpc-12345678"
    public_subnet_ids   = ["subnet-12345678", "subnet-87654321", "subnet-11111111"]
    private_subnet_ids  = ["subnet-22222222", "subnet-33333333", "subnet-44444444"]
  }
  
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

# Override inputs for development environment
inputs = {
  environment = "dev"
  
  # VPC Configuration from dependency
  vpc_id              = dependency.vpc.outputs.vpc_id
  public_subnet_ids   = dependency.vpc.outputs.public_subnet_ids
  private_subnet_ids  = dependency.vpc.outputs.private_subnet_ids
  
  # ECS Configuration - smaller for dev environment
  cluster_name = null  # Will use default naming
  service_name = "web-app"
  
  # Task Configuration - minimal resources for dev
  task_cpu     = 256   # 0.25 vCPU
  task_memory  = 512   # 512 MB
  
  # Scaling Configuration
  desired_count = 1    # Single instance for dev
  min_capacity  = 1
  max_capacity  = 3
  
  # Application Configuration
  container_image = "nginx:latest"
  container_port  = 80
  
  # Health Check Configuration
  health_check_path                    = "/"
  health_check_grace_period_seconds    = 30
  
  # Load Balancer Configuration
  enable_deletion_protection = false  # Allow deletion in dev
  
  # Auto Scaling Thresholds
  scale_up_threshold   = 70
  scale_down_threshold = 30
  
  # Logging Configuration
  log_retention_days = 7  # Short retention for dev
  
  # Environment Variables for the container
  environment_variables = {
    ENVIRONMENT = "development"
    LOG_LEVEL   = "debug"
    NODE_ENV    = "development"
  }
  
  # No secrets for this demo, but this is how you would configure them
  secrets = {
    # DATABASE_PASSWORD = "arn:aws:ssm:eu-west-2:123456789012:parameter/myapp/dev/db-password"
    # API_KEY          = "arn:aws:ssm:eu-west-2:123456789012:parameter/myapp/dev/api-key"
  }
  
  # Additional tags
  additional_tags = {
    CostCenter = "development"
    Owner      = "platform-team"
    Purpose    = "demo-application"
  }
} 