# Terraform AWS Instance Scheduler

This Terraform module deploys the [AWS Instance Scheduler](https://aws.amazon.com/solutions/implementations/instance-scheduler/) solution using CloudFormation templates. The Instance Scheduler automatically starts and stops Amazon EC2 and Amazon RDS instances based on configurable schedules, helping to reduce costs.

## Features

- **Unified Version Management**: Both hub and remote stacks use consistent versioning
- **AWS Organizations Support**: Automatic spoke account registration
- **Multi-Region Scheduling**: Schedule instances across multiple AWS regions
- **Multiple Services**: Support for EC2, RDS, and Auto Scaling Groups
- **Flexible Deployment**: Deploy hub only, remote only, or both together
- **Environment Agnostic**: Works across different AWS environments

## Architecture

The solution consists of two main components:

- **Hub Stack**: Central scheduler deployed in the main account that manages scheduling logic
- **Remote Stack**: Deployed in secondary accounts to provide permissions for cross-account scheduling

## Usage

### Basic Hub Stack Deployment

```hcl
module "instance_scheduler" {
  source = "mjraadi/instance-scheduler/aws"
  version = "~> 1.0"

  # Deploy hub stack only
  deploy_hub_stack = true
  solution_version = "latest"

  # Basic configuration
  stack_name       = "instance-scheduler-hub"
  schedule_tag_key = "Schedule"
  regions          = ["us-east-1", "us-west-2"]

  # Enable services
  enable_ec2_scheduling = true
  enable_rds_scheduling = true
}
```

### AWS Organizations Integration

```hcl
module "instance_scheduler" {
  source = "mjraadi/instance-scheduler/aws"
  version = "~> 1.0"

  deploy_hub_stack      = true
  use_aws_organizations = true
  organization_id       = "o-xxxxxxxxxx"
  namespace            = "prod"

  stack_name       = "instance-scheduler-org"
  solution_version = "v3.0.10"
}
```

### Cross-Account Manual Registration

```hcl
# Hub account
module "instance_scheduler_hub" {
  source = "mjraadi/instance-scheduler/aws"
  version = "~> 1.0"

  deploy_hub_stack   = true
  remote_account_ids = ["111111111111", "222222222222"]
  stack_name         = "instance-scheduler-hub"
}

# Remote account
module "instance_scheduler_remote" {
  source = "mjraadi/instance-scheduler/aws"
  version = "~> 1.0"

  deploy_remote_stack = true
  hub_account_id      = "333333333333"
  remote_stack_name   = "instance-scheduler-remote"
}
```

## Examples

- [Basic Deployment](./examples/basic/) - Simple hub stack deployment
- [AWS Organizations](./examples/organizations/) - Organizations integration
- [Remote Stack](./examples/remote-stack/) - Secondary account deployment

## Requirements

- Terraform >= 1.0.7
- AWS Provider >= 5.0.0
- AWS CLI configured with appropriate permissions

## Version Compatibility

| Module Version | AWS Solution Version | Terraform Version |
| -------------- | -------------------- | ----------------- |
| ~> 1.0         | v3.0.10+             | >= 1.0.7          |

## Configuration

### Solution Versioning

The module supports both latest and specific versions:

```hcl
solution_version = "latest"    # Use latest version
solution_version = "v3.0.10"   # Use specific version
```

### Schedule Configuration

After deployment, configure schedules using the AWS CLI:

```bash
# Create a schedule
aws events put-rule \
  --name "business-hours" \
  --schedule-expression "cron(0 8 ? * MON-FRI *)" \
  --state ENABLED

# Tag instances to use the schedule
aws ec2 create-tags \
  --resources i-1234567890abcdef0 \
  --tags Key=Schedule,Value=business-hours
```

### Supported Services

- **EC2 Instances**: Start/stop EC2 instances
- **RDS Instances**: Start/stop RDS database instances
- **Auto Scaling Groups**: Scale ASGs up/down based on schedules

## Security Considerations

- The module creates IAM roles with permissions to manage EC2, RDS, and ASG resources
- Cross-account access is controlled through IAM roles and policies
- All communications use AWS APIs with proper authentication
- CloudFormation stacks can be protected with termination protection

## Cost Optimization

The Instance Scheduler helps reduce costs by:

- Automatically stopping non-production instances during off-hours
- Scaling down Auto Scaling Groups when not needed
- Providing detailed scheduling reports and metrics
- Supporting complex scheduling patterns for different use cases

## Monitoring

The solution provides:

- CloudWatch metrics for scheduling activities
- CloudWatch logs for debugging and audit trails
- Optional operational dashboard for insights
- SNS notifications for scheduling events

## Limitations

- Schedules are defined at the solution level, not per-instance
- Minimum scheduling interval is 1 minute
- Cross-account scheduling requires network connectivity
- Some RDS features (like snapshots) may have additional delays

## Support

For issues and questions:

1. Check the [AWS Instance Scheduler documentation](https://docs.aws.amazon.com/solutions/latest/instance-scheduler-on-aws/)
2. Review the [examples](./examples/) directory
3. Open an issue in this repository

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_timezone"></a> [default\_timezone](#input\_default\_timezone) | Default IANA timezone identifier for schedules that do not specify a timezone | `string` | `"UTC"` | no |
| <a name="input_deploy_hub_stack"></a> [deploy\_hub\_stack](#input\_deploy\_hub\_stack) | Whether to deploy the Instance Scheduler hub stack | `bool` | `true` | no |
| <a name="input_deploy_remote_stack"></a> [deploy\_remote\_stack](#input\_deploy\_remote\_stack) | Whether to deploy the Instance Scheduler remote stack | `bool` | `false` | no |
| <a name="input_enable_asg_scheduling"></a> [enable\_asg\_scheduling](#input\_enable\_asg\_scheduling) | Enable scheduling for Auto Scaling Groups | `bool` | `false` | no |
| <a name="input_enable_debug_logging"></a> [enable\_debug\_logging](#input\_enable\_debug\_logging) | Enable debug-level logging in CloudWatch logs | `bool` | `false` | no |
| <a name="input_enable_ec2_scheduling"></a> [enable\_ec2\_scheduling](#input\_enable\_ec2\_scheduling) | Enable scheduling for EC2 instances | `bool` | `true` | no |
| <a name="input_enable_hub_account_scheduling"></a> [enable\_hub\_account\_scheduling](#input\_enable\_hub\_account\_scheduling) | Enable scheduling of instances within the hub account | `bool` | `true` | no |
| <a name="input_enable_operational_monitoring"></a> [enable\_operational\_monitoring](#input\_enable\_operational\_monitoring) | Deploy operational insights dashboard and custom metrics | `bool` | `true` | no |
| <a name="input_enable_rds_scheduling"></a> [enable\_rds\_scheduling](#input\_enable\_rds\_scheduling) | Enable scheduling for RDS instances | `bool` | `true` | no |
| <a name="input_hub_account_id"></a> [hub\_account\_id](#input\_hub\_account\_id) | Account ID of the Instance Scheduler hub stack (required for remote stack deployment) | `string` | `null` | no |
| <a name="input_kms_key_arns_ec2"></a> [kms\_key\_arns\_ec2](#input\_kms\_key\_arns\_ec2) | Comma-separated list of KMS ARNs for EC2 encrypted EBS volumes | `string` | `""` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log retention period in days | `number` | `30` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Memory size in MB for the Lambda function | `number` | `128` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Unique identifier to differentiate between multiple solution deployments | `string` | `"default"` | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | AWS Organization ID (required when use\_aws\_organizations is true) | `string` | `null` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | List of AWS regions where instances will be scheduled | `list(string)` | `[]` | no |
| <a name="input_remote_account_ids"></a> [remote\_account\_ids](#input\_remote\_account\_ids) | List of AWS account IDs to schedule (used when not using AWS Organizations) | `list(string)` | `[]` | no |
| <a name="input_remote_stack_name"></a> [remote\_stack\_name](#input\_remote\_stack\_name) | Name for the Instance Scheduler remote CloudFormation stack | `string` | `"instance-scheduler-remote"` | no |
| <a name="input_schedule_tag_key"></a> [schedule\_tag\_key](#input\_schedule\_tag\_key) | The tag key that the solution reads to determine the schedule for a resource | `string` | `"Schedule"` | no |
| <a name="input_scheduling_enabled"></a> [scheduling\_enabled](#input\_scheduling\_enabled) | Enable/disable scheduling for all services | `bool` | `true` | no |
| <a name="input_scheduling_interval_minutes"></a> [scheduling\_interval\_minutes](#input\_scheduling\_interval\_minutes) | Interval in minutes between scheduler runs | `number` | `5` | no |
| <a name="input_solution_version"></a> [solution\_version](#input\_solution\_version) | Version of the Instance Scheduler solution to deploy for both hub and remote stacks | `string` | `"latest"` | no |
| <a name="input_stack_name"></a> [stack\_name](#input\_stack\_name) | Name for the Instance Scheduler hub CloudFormation stack | `string` | `"instance-scheduler-hub"` | no |
| <a name="input_stack_tags"></a> [stack\_tags](#input\_stack\_tags) | Additional tags to apply to the CloudFormation stacks | `map(string)` | `{}` | no |
| <a name="input_stack_timeout_minutes"></a> [stack\_timeout\_minutes](#input\_stack\_timeout\_minutes) | Timeout for CloudFormation stack operations in minutes | `number` | `30` | no |
| <a name="input_use_aws_organizations"></a> [use\_aws\_organizations](#input\_use\_aws\_organizations) | Use AWS Organizations to automate spoke account registration | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_current_account_id"></a> [current\_account\_id](#output\_current\_account\_id) | AWS account ID where the module is deployed |
| <a name="output_current_region"></a> [current\_region](#output\_current\_region) | AWS region where the module is deployed |
| <a name="output_dynamodb_table_name"></a> [dynamodb\_table\_name](#output\_dynamodb\_table\_name) | Name of the DynamoDB configuration table |
| <a name="output_hub_parameters"></a> [hub\_parameters](#output\_hub\_parameters) | Parameters passed to the hub CloudFormation stack |
| <a name="output_hub_stack_id"></a> [hub\_stack\_id](#output\_hub\_stack\_id) | CloudFormation stack ID for the hub stack |
| <a name="output_hub_stack_name"></a> [hub\_stack\_name](#output\_hub\_stack\_name) | CloudFormation stack name for the hub stack |
| <a name="output_hub_stack_region"></a> [hub\_stack\_region](#output\_hub\_stack\_region) | AWS region where the hub stack is deployed |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | Namespace used for this deployment |
| <a name="output_remote_parameters"></a> [remote\_parameters](#output\_remote\_parameters) | Parameters passed to the remote CloudFormation stack |
| <a name="output_remote_stack_id"></a> [remote\_stack\_id](#output\_remote\_stack\_id) | CloudFormation stack ID for the remote stack |
| <a name="output_remote_stack_name"></a> [remote\_stack\_name](#output\_remote\_stack\_name) | CloudFormation stack name for the remote stack |
| <a name="output_remote_stack_region"></a> [remote\_stack\_region](#output\_remote\_stack\_region) | AWS region where the remote stack is deployed |
| <a name="output_schedule_tag_key"></a> [schedule\_tag\_key](#output\_schedule\_tag\_key) | Tag key used for instance scheduling |
| <a name="output_scheduler_role_arn"></a> [scheduler\_role\_arn](#output\_scheduler\_role\_arn) | ARN of the Instance Scheduler IAM role |
| <a name="output_service_token"></a> [service\_token](#output\_service\_token) | Service token for the Instance Scheduler |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of the Instance Scheduler SNS topic |
| <a name="output_solution_version"></a> [solution\_version](#output\_solution\_version) | Version of the Instance Scheduler solution deployed |
| <a name="output_template_urls"></a> [template\_urls](#output\_template\_urls) | CloudFormation template URLs used for deployment |
<!-- END_TF_DOCS -->
