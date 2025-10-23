/**
 * AWS Instance Scheduler Hub Stack
 * 
 * Deploys the main Instance Scheduler CloudFormation stack that manages
 * scheduling logic and coordinates with remote stacks.
 */

# =============================================================================
# Hub Stack CloudFormation Deployment
# =============================================================================

resource "aws_cloudformation_stack" "hub_stack" {
  count = var.deploy_hub_stack ? 1 : 0

  name         = var.stack_name
  template_url = local.hub_template_url
  parameters   = local.hub_parameters_filtered

  capabilities       = local.stack_capabilities
  disable_rollback   = false
  notification_arns  = []
  on_failure         = "ROLLBACK"
  timeout_in_minutes = var.stack_timeout_minutes

  tags = local.hub_stack_tags

  lifecycle {
    # Prevent accidental destruction of the stack
    prevent_destroy = false

    # Ignore changes to template_url to allow for updates
    ignore_changes = []
  }

  depends_on = [
    null_resource.validation
  ]
}

# =============================================================================
# Hub Stack Outputs (for use by remote stacks)
# =============================================================================

# Extract important outputs from the hub stack for use by remote stacks
locals {
  hub_stack_outputs = var.deploy_hub_stack ? {
    scheduler_role_arn = try(
      aws_cloudformation_stack.hub_stack[0].outputs["SchedulerRoleArn"],
      null
    )
    dynamodb_table_name = try(
      aws_cloudformation_stack.hub_stack[0].outputs["ConfigurationTable"],
      null
    )
    sns_topic_arn = try(
      aws_cloudformation_stack.hub_stack[0].outputs["IssueSnsTopicArn"],
      null
    )
    service_token = try(
      aws_cloudformation_stack.hub_stack[0].outputs["ServiceInstanceScheduleServiceToken"],
      null
    )
    account_id = try(
      aws_cloudformation_stack.hub_stack[0].outputs["AccountId"],
      null
    )
  } : {}
}