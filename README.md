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

| Name                                                | Version  |
| --------------------------------------------------- | -------- |
| <a name="provider_aws"></a> [aws](#provider_aws)    | >= 5.0.0 |
| <a name="provider_null"></a> [null](#provider_null) | >= 3.0.0 |

## Inputs

| Name                                                                                                                     | Description                                                                           | Type           | Default                       | Required |
| ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------- | -------------- | ----------------------------- | :------: |
| <a name="input_default_timezone"></a> [default_timezone](#input_default_timezone)                                        | Default IANA timezone identifier for schedules that do not specify a timezone         | `string`       | `"UTC"`                       |    no    |
| <a name="input_deploy_hub_stack"></a> [deploy_hub_stack](#input_deploy_hub_stack)                                        | Whether to deploy the Instance Scheduler hub stack                                    | `bool`         | `true`                        |    no    |
| <a name="input_deploy_remote_stack"></a> [deploy_remote_stack](#input_deploy_remote_stack)                               | Whether to deploy the Instance Scheduler remote stack                                 | `bool`         | `false`                       |    no    |
| <a name="input_enable_asg_scheduling"></a> [enable_asg_scheduling](#input_enable_asg_scheduling)                         | Enable scheduling for Auto Scaling Groups                                             | `bool`         | `false`                       |    no    |
| <a name="input_enable_debug_logging"></a> [enable_debug_logging](#input_enable_debug_logging)                            | Enable debug-level logging in CloudWatch logs                                         | `bool`         | `false`                       |    no    |
| <a name="input_enable_ec2_scheduling"></a> [enable_ec2_scheduling](#input_enable_ec2_scheduling)                         | Enable scheduling for EC2 instances                                                   | `bool`         | `true`                        |    no    |
| <a name="input_enable_hub_account_scheduling"></a> [enable_hub_account_scheduling](#input_enable_hub_account_scheduling) | Enable scheduling of instances within the hub account                                 | `bool`         | `true`                        |    no    |
| <a name="input_enable_operational_monitoring"></a> [enable_operational_monitoring](#input_enable_operational_monitoring) | Deploy operational insights dashboard and custom metrics                              | `bool`         | `true`                        |    no    |
| <a name="input_enable_rds_scheduling"></a> [enable_rds_scheduling](#input_enable_rds_scheduling)                         | Enable scheduling for RDS instances                                                   | `bool`         | `true`                        |    no    |
| <a name="input_hub_account_id"></a> [hub_account_id](#input_hub_account_id)                                              | Account ID of the Instance Scheduler hub stack (required for remote stack deployment) | `string`       | `null`                        |    no    |
| <a name="input_kms_key_arns_ec2"></a> [kms_key_arns_ec2](#input_kms_key_arns_ec2)                                        | Comma-separated list of KMS ARNs for EC2 encrypted EBS volumes                        | `string`       | `""`                          |    no    |
| <a name="input_log_retention_days"></a> [log_retention_days](#input_log_retention_days)                                  | CloudWatch log retention period in days                                               | `number`       | `30`                          |    no    |
| <a name="input_memory_size"></a> [memory_size](#input_memory_size)                                                       | Memory size in MB for the Lambda function                                             | `number`       | `128`                         |    no    |
| <a name="input_namespace"></a> [namespace](#input_namespace)                                                             | Unique identifier to differentiate between multiple solution deployments              | `string`       | `"default"`                   |    no    |
| <a name="input_organization_id"></a> [organization_id](#input_organization_id)                                           | AWS Organization ID (required when use_aws_organizations is true)                     | `string`       | `null`                        |    no    |
| <a name="input_regions"></a> [regions](#input_regions)                                                                   | List of AWS regions where instances will be scheduled                                 | `list(string)` | `[]`                          |    no    |
| <a name="input_remote_account_ids"></a> [remote_account_ids](#input_remote_account_ids)                                  | List of AWS account IDs to schedule (used when not using AWS Organizations)           | `list(string)` | `[]`                          |    no    |
| <a name="input_remote_stack_name"></a> [remote_stack_name](#input_remote_stack_name)                                     | Name for the Instance Scheduler remote CloudFormation stack                           | `string`       | `"instance-scheduler-remote"` |    no    |
| <a name="input_schedule_tag_key"></a> [schedule_tag_key](#input_schedule_tag_key)                                        | The tag key that the solution reads to determine the schedule for a resource          | `string`       | `"Schedule"`                  |    no    |
| <a name="input_scheduling_enabled"></a> [scheduling_enabled](#input_scheduling_enabled)                                  | Enable/disable scheduling for all services                                            | `bool`         | `true`                        |    no    |
| <a name="input_scheduling_interval_minutes"></a> [scheduling_interval_minutes](#input_scheduling_interval_minutes)       | Interval in minutes between scheduler runs                                            | `number`       | `5`                           |    no    |
| <a name="input_solution_version"></a> [solution_version](#input_solution_version)                                        | Version of the Instance Scheduler solution to deploy for both hub and remote stacks   | `string`       | `"latest"`                    |    no    |
| <a name="input_stack_name"></a> [stack_name](#input_stack_name)                                                          | Name for the Instance Scheduler hub CloudFormation stack                              | `string`       | `"instance-scheduler-hub"`    |    no    |
| <a name="input_stack_tags"></a> [stack_tags](#input_stack_tags)                                                          | Additional tags to apply to the CloudFormation stacks                                 | `map(string)`  | `{}`                          |    no    |
| <a name="input_stack_timeout_minutes"></a> [stack_timeout_minutes](#input_stack_timeout_minutes)                         | Timeout for CloudFormation stack operations in minutes                                | `number`       | `30`                          |    no    |
| <a name="input_use_aws_organizations"></a> [use_aws_organizations](#input_use_aws_organizations)                         | Use AWS Organizations to automate spoke account registration                          | `bool`         | `false`                       |    no    |

## Outputs

| Name                                                                                                  | Description                                               |
| ----------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| <a name="output_cross_account_role_arn"></a> [cross_account_role_arn](#output_cross_account_role_arn) | ARN of the cross-account IAM role for remote stack access |
| <a name="output_current_account_id"></a> [current_account_id](#output_current_account_id)             | AWS account ID where the module is deployed               |
| <a name="output_current_region"></a> [current_region](#output_current_region)                         | AWS region where the module is deployed                   |
| <a name="output_dynamodb_table_name"></a> [dynamodb_table_name](#output_dynamodb_table_name)          | Name of the DynamoDB configuration table                  |
| <a name="output_hub_parameters"></a> [hub_parameters](#output_hub_parameters)                         | Parameters passed to the hub CloudFormation stack         |
| <a name="output_hub_stack_id"></a> [hub_stack_id](#output_hub_stack_id)                               | CloudFormation stack ID for the hub stack                 |
| <a name="output_hub_stack_name"></a> [hub_stack_name](#output_hub_stack_name)                         | CloudFormation stack name for the hub stack               |
| <a name="output_hub_stack_region"></a> [hub_stack_region](#output_hub_stack_region)                   | AWS region where the hub stack is deployed                |
| <a name="output_lambda_function_arn"></a> [lambda_function_arn](#output_lambda_function_arn)          | ARN of the Instance Scheduler Lambda function             |
| <a name="output_namespace"></a> [namespace](#output_namespace)                                        | Namespace used for this deployment                        |
| <a name="output_remote_parameters"></a> [remote_parameters](#output_remote_parameters)                | Parameters passed to the remote CloudFormation stack      |
| <a name="output_remote_stack_id"></a> [remote_stack_id](#output_remote_stack_id)                      | CloudFormation stack ID for the remote stack              |
| <a name="output_remote_stack_name"></a> [remote_stack_name](#output_remote_stack_name)                | CloudFormation stack name for the remote stack            |
| <a name="output_remote_stack_region"></a> [remote_stack_region](#output_remote_stack_region)          | AWS region where the remote stack is deployed             |
| <a name="output_schedule_tag_key"></a> [schedule_tag_key](#output_schedule_tag_key)                   | Tag key used for instance scheduling                      |
| <a name="output_scheduler_role_arn"></a> [scheduler_role_arn](#output_scheduler_role_arn)             | ARN of the Instance Scheduler IAM role                    |
| <a name="output_sns_topic_arn"></a> [sns_topic_arn](#output_sns_topic_arn)                            | ARN of the Instance Scheduler SNS topic                   |
| <a name="output_solution_version"></a> [solution_version](#output_solution_version)                   | Version of the Instance Scheduler solution deployed       |
| <a name="output_template_urls"></a> [template_urls](#output_template_urls)                            | CloudFormation template URLs used for deployment          |

<!-- END_TF_DOCS -->
