#!/bin/bash

# Terragrunt Demo Deployment Script
# This script provides convenient wrappers around common Terragrunt commands

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="dev"
REGION="eu-west-2"
ACTION=""
COMPONENT=""

# Function to print usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment    Environment (dev, prod) [default: dev]"
    echo "  -r, --region         AWS Region [default: eu-west-2]"
    echo "  -a, --action         Action (plan, apply, destroy, validate)"
    echo "  -c, --component      Component (vpc, ecs-app, all)"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -a plan -c vpc -e dev"
    echo "  $0 -a apply -c all -e dev"
    echo "  $0 -a destroy -c ecs-app -e prod"
    exit 1
}

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if terragrunt is installed
    if ! command -v terragrunt &> /dev/null; then
        print_error "Terragrunt is not installed. Please install it first."
        exit 1
    fi
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check if AWS CLI is configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured or credentials are invalid."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to set AWS account ID environment variable
set_aws_account_id() {
    export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    print_status "Using AWS Account ID: $AWS_ACCOUNT_ID"
}

# Function to execute terragrunt command
execute_terragrunt() {
    local component=$1
    local action=$2
    local path="environments/${REGION}/${ENVIRONMENT}/${component}"
    
    if [ ! -d "$path" ]; then
        print_error "Path $path does not exist"
        exit 1
    fi
    
    print_status "Executing terragrunt $action in $path"
    
    cd "$path"
    
    case $action in
        "plan")
            terragrunt plan
            ;;
        "apply")
            terragrunt apply
            ;;
        "destroy")
            print_warning "This will destroy resources in $ENVIRONMENT environment!"
            read -p "Are you sure? (yes/no): " confirmation
            if [ "$confirmation" = "yes" ]; then
                terragrunt destroy
            else
                print_status "Destroy cancelled"
            fi
            ;;
        "validate")
            terragrunt validate
            ;;
        *)
            print_error "Unknown action: $action"
            exit 1
            ;;
    esac
    
    cd - > /dev/null
}

# Function to deploy all components
deploy_all() {
    local action=$1
    
    print_status "Deploying all components in $ENVIRONMENT environment"
    
    # Deploy VPC first
    execute_terragrunt "vpc" "$action"
    
    # Deploy ECS application (depends on VPC)
    execute_terragrunt "ecs-app" "$action"
    
    print_success "All components processed successfully"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -r|--region)
            REGION="$2"
            shift 2
            ;;
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        -c|--component)
            COMPONENT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required parameters
if [ -z "$ACTION" ]; then
    print_error "Action is required"
    usage
fi

if [ -z "$COMPONENT" ]; then
    print_error "Component is required"
    usage
fi

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|prod)$ ]]; then
    print_error "Environment must be 'dev' or 'prod'"
    exit 1
fi

# Validate component
if [[ ! "$COMPONENT" =~ ^(vpc|ecs-app|all)$ ]]; then
    print_error "Component must be 'vpc', 'ecs-app', or 'all'"
    exit 1
fi

# Main execution
print_status "Starting deployment with the following parameters:"
print_status "  Environment: $ENVIRONMENT"
print_status "  Region: $REGION"
print_status "  Action: $ACTION"
print_status "  Component: $COMPONENT"

check_prerequisites
set_aws_account_id

if [ "$COMPONENT" = "all" ]; then
    deploy_all "$ACTION"
else
    execute_terragrunt "$COMPONENT" "$ACTION"
fi

print_success "Script completed successfully!" 