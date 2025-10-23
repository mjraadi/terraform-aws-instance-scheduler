/**
 * AWS Instance Scheduler Terraform Module Outputs
 * 
 * Provides access to important stack information and resource ARNs
 * for integration with other infrastructure components.
 */

# =============================================================================
# Hub Stack Outputs
# =============================================================================

output "hub_stack_id" {
  description = "CloudFormation stack ID for the hub stack"
  value       = var.deploy_hub_stack ? aws_cloudformation_stack.hub_stack[0].id : null
}

output "hub_stack_name" {
  description = "CloudFormation stack name for the hub stack"
  value       = var.deploy_hub_stack ? var.stack_name : null
}

output "hub_stack_region" {
  description = "AWS region where the hub stack is deployed"
  value       = var.deploy_hub_stack ? aws_cloudformation_stack.hub_stack[0].region : null
}

output "scheduler_role_arn" {
  description = "ARN of the Instance Scheduler IAM role"
  value       = var.deploy_hub_stack ? local.hub_stack_outputs.scheduler_role_arn : null
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB configuration table"
  value       = var.deploy_hub_stack ? local.hub_stack_outputs.dynamodb_table_name : null
}

output "lambda_function_arn" {
  description = "ARN of the Instance Scheduler Lambda function"
  value       = var.deploy_hub_stack ? local.hub_stack_outputs.lambda_function_arn : null
}

output "sns_topic_arn" {
  description = "ARN of the Instance Scheduler SNS topic"
  value       = var.deploy_hub_stack ? local.hub_stack_outputs.sns_topic_arn : null
}

# =============================================================================
# Remote Stack Outputs
# =============================================================================

output "remote_stack_id" {
  description = "CloudFormation stack ID for the remote stack"
  value       = var.deploy_remote_stack ? aws_cloudformation_stack.remote_stack[0].id : null
}

output "remote_stack_name" {
  description = "CloudFormation stack name for the remote stack"
  value       = var.deploy_remote_stack ? var.remote_stack_name : null
}

output "remote_stack_region" {
  description = "AWS region where the remote stack is deployed"
  value       = var.deploy_remote_stack ? aws_cloudformation_stack.remote_stack[0].region : null
}

output "cross_account_role_arn" {
  description = "ARN of the cross-account IAM role for remote stack access"
  value       = var.deploy_remote_stack ? local.remote_stack_outputs.cross_account_role_arn : null
}

# =============================================================================
# Configuration Outputs
# =============================================================================

output "solution_version" {
  description = "Version of the Instance Scheduler solution deployed"
  value       = var.solution_version
}

output "schedule_tag_key" {
  description = "Tag key used for instance scheduling"
  value       = var.schedule_tag_key
}

output "namespace" {
  description = "Namespace used for this deployment"
  value       = var.namespace
}

output "current_account_id" {
  description = "AWS account ID where the module is deployed"
  value       = local.current_account_id
}

output "current_region" {
  description = "AWS region where the module is deployed"
  value       = local.current_region
}

output "template_urls" {
  description = "CloudFormation template URLs used for deployment"
  value = {
    hub_template    = local.hub_template_url
    remote_template = local.remote_template_url
  }
}

# =============================================================================
# Stack Parameters (for debugging and reference)
# =============================================================================

output "hub_parameters" {
  description = "Parameters passed to the hub CloudFormation stack"
  value       = var.deploy_hub_stack ? local.hub_parameters_filtered : {}
  sensitive   = false
}

output "remote_parameters" {
  description = "Parameters passed to the remote CloudFormation stack"
  value       = var.deploy_remote_stack ? local.remote_parameters_filtered : {}
  sensitive   = false
}