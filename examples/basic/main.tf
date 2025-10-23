#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

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
# Basic Example: Hub Stack Only
# =============================================================================

module "instance_scheduler_hub" {
  source = "../.."

  # Deploy only the hub stack
  deploy_hub_stack    = true
  deploy_remote_stack = false

  # Use latest version of the solution
  solution_version = "latest"

  # Basic configuration
  stack_name                  = "instance-scheduler-hub"
  schedule_tag_key            = "Schedule"
  scheduling_interval_minutes = 5
  default_timezone            = "UTC"

  # Enable scheduling for EC2 and RDS
  scheduling_enabled    = true
  enable_ec2_scheduling = true
  enable_rds_scheduling = true
  enable_asg_scheduling = false

  # Configure for multiple regions
  regions = ["us-east-1", "us-west-2"]

  # Enable hub account scheduling
  enable_hub_account_scheduling = true

  # Manual account registration (not using Organizations)
  use_aws_organizations = false
  remote_account_ids    = [] # Add account IDs here for cross-account scheduling

  # Advanced settings
  memory_size                   = 128
  log_retention_days            = 30
  enable_debug_logging          = false
  enable_operational_monitoring = true

  # Additional stack tags
  stack_tags = {
    Environment = "dev"
    Project     = "instance-scheduler"
    Owner       = "platform-team"
  }
}
