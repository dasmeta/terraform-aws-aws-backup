# terraform-aws-backup

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sns_topic"></a> [sns\_topic](#module\_sns\_topic) | terraform-aws-modules/sns/aws | ~> 3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_backup_plan.daily](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) | resource |
| [aws_backup_selection.tagged_daily](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection) | resource |
| [aws_backup_vault.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault) | resource |
| [aws_backup_vault_notifications.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault_notifications) | resource |
| [aws_iam_role.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_restore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.backup_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_permission.with_sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_sns_topic_subscription.email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_backup_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.backup_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.backup_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_email_addresses"></a> [alarm\_email\_addresses](#input\_alarm\_email\_addresses) | E-Mail addresses that should be subscribed to monitoring notifications | `list(string)` | `[]` | no |
| <a name="input_alarm_lambda_arn"></a> [alarm\_lambda\_arn](#input\_alarm\_lambda\_arn) | ARN of a lambda function that should be subscribed to monitoring notifications | `string` | `""` | no |
| <a name="input_backup_plan_name"></a> [backup\_plan\_name](#input\_backup\_plan\_name) | Initial part of the plan name to which will be appended the env | `string` | `""` | no |
| <a name="input_backup_retention_days"></a> [backup\_retention\_days](#input\_backup\_retention\_days) | Number of days recovery points should be kept. | `number` | `7` | no |
| <a name="input_backup_schedule"></a> [backup\_schedule](#input\_backup\_schedule) | Schedule of aws backup plan | `string` | `"cron(0 1 * * ? *)"` | no |
| <a name="input_enable_continuous_backup"></a> [enable\_continuous\_backup](#input\_enable\_continuous\_backup) | Flag to enable continuos backup | `bool` | `false` | no |
| <a name="input_enable_sns_notifications"></a> [enable\_sns\_notifications](#input\_enable\_sns\_notifications) | Create an SNS topic where backup notifications go | `bool` | `true` | no |
| <a name="input_env"></a> [env](#input\_env) | Deployment environment | `string` | n/a | yes |
| <a name="input_plan_selection_tag"></a> [plan\_selection\_tag](#input\_plan\_selection\_tag) | Resource selection for the plan | `list(map)` | <pre>[<br/>  {<br/>    "key": "",<br/>    "value": ""<br/>  }<br/>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The region where resources should be managed. | `string` | `"eu-central-1"` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | List of rules to attach to the plan | `list(map)` | <pre>[<br/>  {<br/>    "continuous_backup": true,<br/>    "name": "daily",<br/>    "recovery_point_tags": {<br/>      "Environment": "dev",<br/>      "Plan": "plan name"<br/>    },<br/>    "schedule": "cron(0 12 * * ? *)",<br/>    "vault": "Backup"<br/>  }<br/>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
