terraform {
  required_version = ">= 1.0.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

# =============================================================================
# Remote Stack Example: Deploy in Secondary Account
# =============================================================================

module "instance_scheduler_remote" {
  source = "../.."

  # Deploy only remote stack
  deploy_hub_stack    = false
  deploy_remote_stack = true

  # Must match the version used in the hub stack
  solution_version = "latest"

  # Remote stack configuration
  remote_stack_name = "instance-scheduler-remote"
  hub_account_id    = "123456789012" # Replace with your hub account ID

  # Must match hub stack configuration
  use_aws_organizations = false
  namespace             = "default"

  # KMS configuration for encrypted volumes
  kms_key_arns_ec2 = "*" # Allow access to all KMS keys

  # Stack tags
  stack_tags = {
    Environment = "dev"
    Project     = "instance-scheduler"
    Owner       = "platform-team"
    StackType   = "remote"
  }
}