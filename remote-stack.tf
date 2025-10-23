/**
 * AWS Instance Scheduler Remote Stack
 * 
 * Deploys the remote Instance Scheduler CloudFormation stack in secondary accounts
 * to provide permissions for the hub stack to manage resources.
 */

# =============================================================================
# Remote Stack CloudFormation Deployment
# =============================================================================

resource "aws_cloudformation_stack" "remote_stack" {
  count = var.deploy_remote_stack ? 1 : 0

  name         = var.remote_stack_name
  template_url = local.remote_template_url
  parameters   = local.remote_parameters_filtered

  capabilities       = local.stack_capabilities
  disable_rollback   = false
  notification_arns  = []
  on_failure         = "ROLLBACK"
  timeout_in_minutes = var.stack_timeout_minutes

  tags = local.remote_stack_tags

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
# Remote Stack Outputs
# =============================================================================

# Extract important outputs from the remote stack
locals {
  remote_stack_outputs = var.deploy_remote_stack ? {
    cross_account_role_arn = try(
      aws_cloudformation_stack.remote_stack[0].outputs["CrossAccountRole"],
      null
    )
    stack_id = try(
      aws_cloudformation_stack.remote_stack[0].id,
      null
    )
  } : {}
}