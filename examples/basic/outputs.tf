# =============================================================================
# Basic Example Outputs
# =============================================================================

output "hub_stack_id" {
  description = "CloudFormation stack ID for the hub stack"
  value       = module.instance_scheduler_hub.hub_stack_id
}

output "hub_stack_region" {
  description = "AWS region where the hub stack is deployed"
  value       = module.instance_scheduler_hub.hub_stack_region
}

output "scheduler_role_arn" {
  description = "ARN of the Instance Scheduler IAM role"
  value       = module.instance_scheduler_hub.scheduler_role_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB configuration table"
  value       = module.instance_scheduler_hub.dynamodb_table_name
}

output "service_token" {
  description = "Service token for the Instance Scheduler"
  value       = module.instance_scheduler_hub.service_token
}

output "schedule_tag_key" {
  description = "Tag key used for instance scheduling"
  value       = module.instance_scheduler_hub.schedule_tag_key
}

output "solution_version" {
  description = "Version of the Instance Scheduler solution deployed"
  value       = module.instance_scheduler_hub.solution_version
}