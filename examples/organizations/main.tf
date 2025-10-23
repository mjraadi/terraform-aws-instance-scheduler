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
# AWS Organizations Example: Hub Stack with Organizations Integration
# =============================================================================

module "instance_scheduler_org" {
  source = "../.."

  # Deploy hub stack with Organizations integration
  deploy_hub_stack    = true
  deploy_remote_stack = false

  # Use specific version for production stability
  solution_version = "v3.0.10"

  # Hub stack configuration
  stack_name                  = "instance-scheduler-org-hub"
  schedule_tag_key            = "Schedule"
  scheduling_interval_minutes = 5
  default_timezone            = "America/New_York"

  # Enable scheduling services
  scheduling_enabled    = true
  enable_ec2_scheduling = true
  enable_rds_scheduling = true
  enable_asg_scheduling = true

  # AWS Organizations configuration
  use_aws_organizations = true
  organization_id       = "o-example123456" # Replace with your Organization ID
  namespace             = "prod"

  # Multi-region scheduling
  regions = ["us-east-1", "us-west-2", "eu-west-1"]

  # Production settings
  memory_size                   = 256
  log_retention_days            = 90
  enable_debug_logging          = false
  enable_operational_monitoring = true

  # Production tags
  stack_tags = {
    Environment = "production"
    Project     = "instance-scheduler"
    Owner       = "platform-team"
    CostCenter  = "infrastructure"
  }
}