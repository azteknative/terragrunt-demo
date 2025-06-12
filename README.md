# Terragrunt Demo: ECS Fargate with VPC

This repository demonstrates Terragrunt best practices for managing AWS infrastructure, specifically showcasing:

- **VPC Module**: Creates a complete VPC with public/private subnets, NAT gateways, and internet gateway
- **ECS Fargate Module**: Deploys a containerized application using ECS with Fargate launch type
- **Environment Management**: Separate configurations for development and production
- **DRY Principles**: Terragrunt configurations that minimize code duplication

## Repository Structure

```
terragrunt-demo/
├── modules/                    # Reusable Terraform modules
│   ├── vpc/                   # VPC infrastructure module
│   └── ecs-fargate/          # ECS Fargate application module
├── environments/              # Environment-specific configurations
│   └── eu-west-2/            # Region-specific configurations
│       ├── dev/              # Development environment
│       │   ├── vpc/
│       │   └── ecs-app/
│       └── prod/             # Production environment
│           ├── vpc/
│           └── ecs-app/
├── terragrunt.hcl            # Root Terragrunt configuration
└── README.md
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) >= 0.50
- AWS CLI configured with appropriate credentials
- Docker (for building container images)

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd terragrunt-demo
   ```

2. **Deploy the VPC (Development)**
   ```bash
   cd environments/eu-west-2/dev/vpc
   terragrunt apply
   ```

3. **Deploy the ECS application (Development)**
   ```bash
   cd ../ecs-app
   terragrunt apply
   ```

## Key Features

### VPC Module
- Multi-AZ deployment across 3 availability zones
- Public and private subnets
- NAT gateways for outbound internet access from private subnets
- VPC endpoints for AWS services (optional)
- Proper security group configurations

### ECS Fargate Module
- Application Load Balancer with health checks
- ECS cluster with Fargate tasks
- Auto-scaling based on CPU/memory utilization
- CloudWatch logging and monitoring
- Secrets management via AWS Systems Manager

### Terragrunt Best Practices
- **DRY Configuration**: Common settings defined once in root `terragrunt.hcl`
- **Remote State**: S3 backend with DynamoDB locking
- **Environment Isolation**: Separate state files for each environment
- **Dependency Management**: Explicit dependencies between modules
- **Input Validation**: Comprehensive variable validation

## Environment Management

Each environment (dev/prod) has its own:
- Terraform state file
- Variable values
- Resource naming conventions
- Scaling parameters

### Development Environment
- Smaller instance sizes
- Single NAT gateway
- Reduced redundancy for cost optimization

### Production Environment
- Multi-AZ NAT gateways
- Enhanced monitoring and alerting
- Stricter security configurations

## Deployment Commands

### Deploy Everything
```bash
# From repository root - uses terragrunt run-all with automatic dependency resolution
./scripts/deploy.sh -a apply -c all -e dev

# Traditional terragrunt approach from environment directory
cd environments/eu-west-2/dev
terragrunt run-all apply
```

### Deploy Specific Module
```bash
cd environments/eu-west-2/dev/vpc
terragrunt apply
```

### Plan Changes
```bash
# Plan all components with dependency resolution
./scripts/deploy.sh -a plan -c all -e dev

# Plan specific component
terragrunt plan
```

### Destroy Infrastructure
```bash
# Destroy all components in correct reverse dependency order
./scripts/deploy.sh -a destroy -c all -e dev

# Destroy specific component
terragrunt destroy
```

## Customization

### Adding New Environments
1. Create new directory under `environments/eu-west-2/`
2. Copy configuration files from existing environment
3. Modify variables in `terragrunt.hcl` files

### Adding New Regions
1. Create new directory under `environments/`
2. Update provider configurations
3. Adjust availability zone mappings

## Security Considerations

- All resources are deployed in private subnets where possible
- Security groups follow principle of least privilege
- Secrets are managed via AWS Systems Manager Parameter Store
- VPC Flow Logs enabled for network monitoring

## Cost Optimization

- Development environment uses cost-optimized configurations
- Auto-scaling policies prevent over-provisioning
- Spot instances can be enabled for non-production workloads

## Troubleshooting

### Common Issues
1. **State Lock Errors**: Check DynamoDB table for stuck locks
2. **Permission Errors**: Verify IAM roles and policies
3. **Resource Limits**: Check AWS service quotas

### Useful Commands
```bash
# Check state
terragrunt state list

# Import existing resources
terragrunt import <resource_type>.<resource_name> <resource_id>

# Refresh state
terragrunt refresh
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 