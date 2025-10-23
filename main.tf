/**
 * AWS Instance Scheduler Terraform Module
 * 
 * Deploys the AWS Instance Scheduler solution using CloudFormation templates.
 * Supports both hub and remote stack deployments with consistent versioning.
 */

# =============================================================================
# Data Sources
# =============================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# =============================================================================
# Input Validation
# =============================================================================

# Validation check using local values
resource "null_resource" "validation" {
  count = length(local.validation_errors) > 0 ? 1 : 0

  triggers = {
    validation_errors = join("\n", local.validation_errors)
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Validation errors found:"
      echo "${join("\n", local.validation_errors)}"
      exit 1
    EOT
  }
}

# =============================================================================
# CloudFormation Stack Resources
# =============================================================================

# This module uses separate files for hub and remote stack deployments
# to maintain clear separation of concerns and improve readability.