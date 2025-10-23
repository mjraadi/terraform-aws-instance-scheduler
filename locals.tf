/**
 * Local values for AWS Instance Scheduler Terraform Module
 * 
 * Contains template URL construction, validation logic, and parameter mapping
 */

locals {
  # =============================================================================
  # Template URL Construction (Both stacks use same version)
  # =============================================================================

  base_template_url = "https://s3.amazonaws.com/solutions-reference/instance-scheduler-on-aws/${var.solution_version}"

  hub_template_url    = "${local.base_template_url}/instance-scheduler-on-aws.template"
  remote_template_url = "${local.base_template_url}/instance-scheduler-on-aws-remote.template"

  # =============================================================================
  # Validation Logic
  # =============================================================================

  # Ensure Organizations and manual account IDs are mutually exclusive
  org_config_valid = !(var.use_aws_organizations && length(var.remote_account_ids) > 0)

  # Ensure Organization ID is provided when using Organizations
  org_id_valid = var.use_aws_organizations ? var.organization_id != null : true

  # Ensure namespace is not default when using Organizations
  namespace_valid = var.use_aws_organizations ? var.namespace != "default" : true

  # Ensure hub account ID is provided when deploying remote stack
  remote_hub_account_valid = var.deploy_remote_stack ? var.hub_account_id != null : true

  # Ensure remote stack configuration is consistent with hub stack
  remote_org_consistent = var.deploy_remote_stack && var.deploy_hub_stack ? (
    var.use_aws_organizations ? var.organization_id != null : var.hub_account_id != null
  ) : true

  # Validation error messages
  validation_errors = compact([
    !local.org_config_valid ? "Cannot use both AWS Organizations and manual account IDs" : "",
    !local.org_id_valid ? "Organization ID is required when use_aws_organizations is true" : "",
    !local.namespace_valid ? "Namespace must not be 'default' when using AWS Organizations" : "",
    !local.remote_hub_account_valid ? "Hub account ID is required when deploying remote stack" : "",
    !local.remote_org_consistent ? "Remote stack configuration must be consistent with hub stack" : ""
  ])

  # =============================================================================
  # Current AWS Account and Region
  # =============================================================================

  current_account_id = data.aws_caller_identity.current.account_id
  current_region     = data.aws_region.current.id

  # =============================================================================
  # Hub Stack Parameter Mapping
  # =============================================================================

  hub_parameters = {
    TagName               = var.schedule_tag_key
    SchedulerFrequency    = var.scheduling_interval_minutes
    DefaultTimezone       = var.default_timezone
    SchedulingActive      = var.scheduling_enabled ? "Yes" : "No"
    ScheduleEC2           = var.enable_ec2_scheduling ? "Enabled" : "Disabled"
    ScheduleRds           = var.enable_rds_scheduling ? "Enabled" : "Disabled"
    ScheduleASGs          = var.enable_asg_scheduling ? "Enabled" : "Disabled"
    OpsMonitoring         = var.enable_operational_monitoring ? "Enabled" : "Disabled"
    LogRetentionDays      = var.log_retention_days
    MemorySize            = var.memory_size
    Trace                 = var.enable_debug_logging ? "Yes" : "No"
    UsingAWSOrganizations = var.use_aws_organizations ? "Yes" : "No"
    Namespace             = var.namespace
    ScheduleLambdaAccount = var.enable_hub_account_scheduling ? "Yes" : "No"

    # Conditional parameters based on configuration
    Principals = var.use_aws_organizations ? var.organization_id : join(",", var.remote_account_ids)
    Regions    = length(var.regions) > 0 ? join(",", var.regions) : ""
    KmsKeyArns = var.kms_key_arns_ec2
  }

  # Filter out empty/null parameters for hub stack
  hub_parameters_filtered = {
    for k, v in local.hub_parameters : k => v if v != null && v != ""
  }

  # =============================================================================
  # Remote Stack Parameter Mapping
  # =============================================================================

  remote_parameters = {
    InstanceSchedulerAccount = var.hub_account_id
    UsingAWSOrganizations    = var.use_aws_organizations ? "Yes" : "No"
    Namespace                = var.namespace
    KmsKeyArns               = var.kms_key_arns_ec2
  }

  # Filter out empty/null parameters for remote stack
  remote_parameters_filtered = {
    for k, v in local.remote_parameters : k => v if v != null && v != ""
  }

  # =============================================================================
  # Stack Tags
  # =============================================================================

  default_tags = {
    ManagedBy       = "Terraform"
    Module          = "terraform-aws-instance-scheduler"
    SolutionVersion = var.solution_version
    Namespace       = var.namespace
  }

  hub_stack_tags = merge(
    local.default_tags,
    {
      StackType = "Hub"
      StackName = var.stack_name
    },
    var.stack_tags
  )

  remote_stack_tags = merge(
    local.default_tags,
    {
      StackType  = "Remote"
      StackName  = var.remote_stack_name
      HubAccount = var.hub_account_id
    },
    var.stack_tags
  )

  # =============================================================================
  # Stack Configuration
  # =============================================================================

  # Common stack capabilities required for IAM resource creation
  stack_capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
}