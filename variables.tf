/**
 * AWS Instance Scheduler Terraform Module Variables
 * 
 * This module deploys the AWS Instance Scheduler solution using CloudFormation templates.
 * It supports both hub and remote stack deployments with consistent versioning.
 */

# =============================================================================
# Stack Deployment Configuration
# =============================================================================

variable "deploy_hub_stack" {
  description = "Whether to deploy the Instance Scheduler hub stack"
  type        = bool
  default     = true
}

variable "deploy_remote_stack" {
  description = "Whether to deploy the Instance Scheduler remote stack"
  type        = bool
  default     = false
}

variable "solution_version" {
  description = "Version of the Instance Scheduler solution to deploy for both hub and remote stacks"
  type        = string
  default     = "latest"

  validation {
    condition     = can(regex("^(latest|v\\d+\\.\\d+\\.\\d+)$", var.solution_version))
    error_message = "Solution version must be 'latest' or in format 'vX.Y.Z' (e.g., 'v3.0.10')."
  }
}

# =============================================================================
# Hub Stack Configuration
# =============================================================================

variable "stack_name" {
  description = "Name for the Instance Scheduler hub CloudFormation stack"
  type        = string
  default     = "instance-scheduler-hub"

  validation {
    condition     = can(regex("^[a-zA-Z][-a-zA-Z0-9]*$", var.stack_name))
    error_message = "Stack name must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "schedule_tag_key" {
  description = "The tag key that the solution reads to determine the schedule for a resource"
  type        = string
  default     = "Schedule"
}

variable "scheduling_interval_minutes" {
  description = "Interval in minutes between scheduler runs"
  type        = number
  default     = 5

  validation {
    condition     = var.scheduling_interval_minutes >= 1 && var.scheduling_interval_minutes <= 60
    error_message = "Scheduling interval must be between 1 and 60 minutes."
  }
}

variable "default_timezone" {
  description = "Default IANA timezone identifier for schedules that do not specify a timezone"
  type        = string
  default     = "UTC"
}

variable "scheduling_enabled" {
  description = "Enable/disable scheduling for all services"
  type        = bool
  default     = true
}

variable "enable_ec2_scheduling" {
  description = "Enable scheduling for EC2 instances"
  type        = bool
  default     = true
}

variable "enable_rds_scheduling" {
  description = "Enable scheduling for RDS instances"
  type        = bool
  default     = true
}

variable "enable_asg_scheduling" {
  description = "Enable scheduling for Auto Scaling Groups"
  type        = bool
  default     = false
}

# =============================================================================
# AWS Organizations Configuration
# =============================================================================

variable "use_aws_organizations" {
  description = "Use AWS Organizations to automate spoke account registration"
  type        = bool
  default     = false
}

variable "organization_id" {
  description = "AWS Organization ID (required when use_aws_organizations is true)"
  type        = string
  default     = null

  validation {
    condition     = var.organization_id == null || can(regex("^o-[a-z0-9]{10,32}$", var.organization_id))
    error_message = "Organization ID must be in format 'o-xxxxxxxxxx'."
  }
}

variable "remote_account_ids" {
  description = "List of AWS account IDs to schedule (used when not using AWS Organizations)"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for account_id in var.remote_account_ids : can(regex("^[0-9]{12}$", account_id))
    ])
    error_message = "All account IDs must be exactly 12 digits."
  }
}

variable "namespace" {
  description = "Unique identifier to differentiate between multiple solution deployments"
  type        = string
  default     = "default"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.namespace))
    error_message = "Namespace must contain only alphanumeric characters and hyphens."
  }
}

# =============================================================================
# Regional Configuration
# =============================================================================

variable "regions" {
  description = "List of AWS regions where instances will be scheduled"
  type        = list(string)
  default     = []
}

variable "enable_hub_account_scheduling" {
  description = "Enable scheduling of instances within the hub account"
  type        = bool
  default     = true
}

# =============================================================================
# Remote Stack Configuration
# =============================================================================

variable "remote_stack_name" {
  description = "Name for the Instance Scheduler remote CloudFormation stack"
  type        = string
  default     = "instance-scheduler-remote"

  validation {
    condition     = can(regex("^[a-zA-Z][-a-zA-Z0-9]*$", var.remote_stack_name))
    error_message = "Stack name must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "hub_account_id" {
  description = "Account ID of the Instance Scheduler hub stack (required for remote stack deployment)"
  type        = string
  default     = null

  validation {
    condition     = var.hub_account_id == null || can(regex("^[0-9]{12}$", var.hub_account_id))
    error_message = "Hub account ID must be exactly 12 digits."
  }
}

# =============================================================================
# Advanced Configuration
# =============================================================================

variable "memory_size" {
  description = "Memory size in MB for the Lambda function"
  type        = number
  default     = 128

  validation {
    condition     = contains([128, 256, 512, 1024, 2048, 3008], var.memory_size)
    error_message = "Memory size must be one of: 128, 256, 512, 1024, 2048, 3008."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period."
  }
}

variable "kms_key_arns_ec2" {
  description = "Comma-separated list of KMS ARNs for EC2 encrypted EBS volumes"
  type        = string
  default     = ""
}

variable "enable_debug_logging" {
  description = "Enable debug-level logging in CloudWatch logs"
  type        = bool
  default     = false
}

variable "enable_operational_monitoring" {
  description = "Deploy operational insights dashboard and custom metrics"
  type        = bool
  default     = true
}

# =============================================================================
# CloudFormation Stack Configuration
# =============================================================================

variable "stack_tags" {
  description = "Additional tags to apply to the CloudFormation stacks"
  type        = map(string)
  default     = {}
}

variable "stack_timeout_minutes" {
  description = "Timeout for CloudFormation stack operations in minutes"
  type        = number
  default     = 30

  validation {
    condition     = var.stack_timeout_minutes >= 1 && var.stack_timeout_minutes <= 180
    error_message = "Stack timeout must be between 1 and 180 minutes."
  }
}