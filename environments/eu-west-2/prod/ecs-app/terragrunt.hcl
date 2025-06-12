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

# Override inputs for production environment
inputs = {
  environment = "prod"
  
  # VPC Configuration from dependency
  vpc_id              = dependency.vpc.outputs.vpc_id
  public_subnet_ids   = dependency.vpc.outputs.public_subnet_ids
  private_subnet_ids  = dependency.vpc.outputs.private_subnet_ids
  
  # ECS Configuration - production sizing
  # cluster_name = null  # Will use default naming
  service_name = "web-app"
  
  # Task Configuration - production resources
  task_cpu     = 512   # 0.5 vCPU
  task_memory  = 1024  # 1024 MB
  
  # Scaling Configuration - higher availability
  desired_count = 3    # Multiple instances for production
  min_capacity  = 2    # Always have at least 2 instances
  max_capacity  = 20   # Can scale up to 20 instances
  
  # Application Configuration
  container_image = "nginx:latest"
  container_port  = 80
  
  # Health Check Configuration
  health_check_path                    = "/"
  health_check_grace_period_seconds    = 60  # Longer grace period for prod
  
  # Load Balancer Configuration
  enable_deletion_protection = true   # Protect against accidental deletion
  
  # Auto Scaling Thresholds - more conservative for production
  scale_up_threshold   = 60   # Scale up earlier
  scale_down_threshold = 20   # Scale down more conservatively
  
  # Logging Configuration
  log_retention_days = 30  # Longer retention for production
  
  # Environment Variables for the container
  environment_variables = {
    ENVIRONMENT = "production"
    LOG_LEVEL   = "info"
    NODE_ENV    = "production"
  }
  
  # Production secrets (examples)
  secrets = {
    # DATABASE_PASSWORD = "arn:aws:ssm:eu-west-2:123456789012:parameter/myapp/prod/db-password"
    # API_KEY          = "arn:aws:ssm:eu-west-2:123456789012:parameter/myapp/prod/api-key"
    # JWT_SECRET       = "arn:aws:ssm:eu-west-2:123456789012:parameter/myapp/prod/jwt-secret"
  }
  
  # Additional tags
  additional_tags = {
    CostCenter = "production"
    Owner      = "platform-team"
    Purpose    = "production-application"
    Backup     = "required"
    Monitoring = "enhanced"
    Compliance = "required"
  }
} 