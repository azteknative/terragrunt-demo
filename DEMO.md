# Terragrunt Demo: ECS Fargate with VPC

## Demo Overview

This demo showcases Terragrunt best practices for managing AWS infrastructure at scale, specifically focusing on:

- **Modular Architecture**: Reusable Terraform modules
- **Environment Management**: Separate configurations for dev/prod
- **Dependency Management**: Automatic handling of resource dependencies
- **DRY Principles**: Don't Repeat Yourself configuration
- **AWS ECS Fargate**: Serverless container orchestration

## Demo Flow

### 1. Project Structure Walkthrough (5 minutes)

```
terragrunt-demo/
├── modules/                    # Reusable Terraform modules
│   ├── vpc/                   # VPC infrastructure module
│   │   ├── main.tf           # VPC, subnets, NAT gateways, etc.
│   │   ├── variables.tf      # Input variables with validation
│   │   └── outputs.tf        # Output values for other modules
│   └── ecs-fargate/          # ECS Fargate application module
│       ├── main.tf           # ECS cluster, service, ALB, auto-scaling
│       ├── variables.tf      # Configurable parameters
│       └── outputs.tf        # Service endpoints and ARNs
├── environments/              # Environment-specific configurations
│   └── eu-west-2/            # Region-specific configurations
│       ├── dev/              # Development environment
│       │   ├── vpc/          # Dev VPC configuration
│       │   └── ecs-app/      # Dev ECS application
│       └── prod/             # Production environment
│           ├── vpc/          # Prod VPC configuration
│           └── ecs-app/      # Prod ECS application
├── terragrunt.hcl            # Root configuration (DRY settings)
└── scripts/deploy.sh         # Deployment automation script
```

### 2. Terragrunt Benefits Demonstration (10 minutes)

#### DRY Configuration
- Show how `terragrunt.hcl` eliminates code duplication
- Common provider configuration
- Shared remote state settings
- Default tags applied everywhere

#### Environment Isolation
- Separate state files per environment
- Environment-specific variable values
- Different scaling parameters for dev vs prod

#### Dependency Management
- Show how ECS app depends on VPC
- Automatic dependency resolution
- Mock outputs for planning

### 3. Live Deployment Demo (15 minutes)

#### Prerequisites Check
```bash
# Check if tools are installed
terragrunt --version
terraform --version
aws sts get-caller-identity
```

#### Deploy Development Environment
```bash
# Deploy VPC first
cd environments/eu-west-2/dev/vpc
terragrunt plan
terragrunt apply

# Deploy ECS application (depends on VPC)
cd ../ecs-app
terragrunt plan
terragrunt apply
```

#### Using the Deployment Script
```bash
# Plan all components with automatic dependency resolution
./scripts/deploy.sh -a plan -c all -e dev

# Apply all components - VPC first, then ECS (automatic ordering)
./scripts/deploy.sh -a apply -c all -e dev

# Destroy all components - ECS first, then VPC (automatic reverse ordering)
./scripts/deploy.sh -a destroy -c all -e dev
```

#### Manual Terragrunt Commands
```bash
# From environment directory - terragrunt handles dependencies automatically
cd environments/eu-west-2/dev
terragrunt run-all plan    # Plans all with dependency resolution
terragrunt run-all apply   # Applies in correct order
terragrunt run-all destroy # Destroys in reverse order
```

### 4. Key Features Showcase (10 minutes)

#### VPC Module Features
- Multi-AZ deployment across 3 availability zones
- Public and private subnets with proper routing
- NAT gateways for outbound internet access
- VPC Flow Logs for network monitoring
- Cost optimization options (single NAT for dev)

#### ECS Fargate Module Features
- Application Load Balancer with health checks
- ECS cluster with Fargate launch type
- Auto-scaling based on CPU utilization
- CloudWatch logging integration
- Security groups with least privilege access
- Support for environment variables and secrets

#### Environment Differences
Show the configuration differences between dev and prod:

**Development:**
- Single NAT gateway (cost optimization)
- Smaller instance sizes (256 CPU, 512 MB memory)
- Single task instance
- 7-day log retention
- Deletion protection disabled

**Production:**
- Multi-AZ NAT gateways (high availability)
- Larger instance sizes (512 CPU, 1024 MB memory)
- Multiple task instances (3 desired, 2-20 range)
- 30-day log retention
- Deletion protection enabled

### 5. Operational Benefits (5 minutes)

#### State Management
- Centralized state in S3 with DynamoDB locking
- Separate state files prevent environment conflicts
- State versioning and backup

#### Deployment Safety
- Plan before apply workflow
- Dependency validation
- Resource tagging for cost tracking
- Confirmation prompts for destructive operations

#### Scalability
- Easy to add new environments
- Simple region replication
- Module reusability across projects

## Demo Commands Cheat Sheet

```bash
# Planning
terragrunt plan                          # Plan current directory
terragrunt run-all plan                  # Plan all dependencies

# Applying
terragrunt apply                         # Apply current directory
terragrunt run-all apply                 # Apply all dependencies

# Validation
terragrunt validate                      # Validate configuration
terragrunt run-all validate             # Validate all configurations

# State Management
terragrunt state list                    # List resources in state
terragrunt state show <resource>         # Show resource details

# Using the deployment script
./scripts/deploy.sh -a plan -c all -e dev      # Plan everything in dev
./scripts/deploy.sh -a apply -c vpc -e prod    # Apply VPC in prod
./scripts/deploy.sh -a destroy -c all -e dev   # Destroy everything in dev
```

## Demo Talking Points

### Why Terragrunt?
1. **Eliminates Code Duplication**: Common configurations defined once
2. **Environment Management**: Clean separation between environments
3. **Dependency Handling**: Automatic resolution of resource dependencies
4. **Remote State Management**: Built-in S3 backend configuration
5. **Team Collaboration**: Consistent practices across team members

### Why ECS Fargate?
1. **Serverless Containers**: No EC2 instance management
2. **Auto Scaling**: Automatic scaling based on demand
3. **Cost Effective**: Pay only for resources used
4. **Security**: Built-in network isolation
5. **Integration**: Seamless AWS service integration

### Production Readiness
1. **Security**: VPC isolation, security groups, IAM roles
2. **Monitoring**: CloudWatch logs, Container Insights
3. **High Availability**: Multi-AZ deployment
4. **Auto Scaling**: CPU-based scaling policies
5. **Cost Optimization**: Environment-specific sizing

## Q&A Preparation

**Q: How does this compare to CloudFormation?**
A: Terragrunt + Terraform provides better modularity, state management, and multi-cloud support while maintaining AWS-native best practices.

**Q: What about secrets management?**
A: The demo shows integration with AWS Systems Manager Parameter Store for secure secret handling.

**Q: How do we handle database connections?**
A: ECS tasks run in private subnets with controlled egress, perfect for secure database connectivity.

**Q: Can we use this pattern for other applications?**
A: Absolutely! The modules are generic and can be customized for any containerized application.

**Q: What about CI/CD integration?**
A: The deployment script can be easily integrated into CI/CD pipelines with proper credential handling.

## Next Steps

1. **Pilot Project**: Start with a non-critical application
2. **Team Training**: Provide Terragrunt and Terraform training
3. **Standards Definition**: Establish module standards and practices
4. **Pipeline Integration**: Integrate with existing CI/CD tools
5. **Security Review**: Conduct security assessment of configurations 