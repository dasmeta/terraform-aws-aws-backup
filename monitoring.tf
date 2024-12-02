data "aws_iam_policy_document" "kms" {
  # Copy of default KMS policy that lets you manage it
  #checkov:skip=CKV_AWS_111: Does not apply here because KMS key policies only apply to the key itself. (https://docs.bridgecrew.io/docs/ensure-iam-policies-do-not-allow-write-access-without-constraint)
  #checkov:skip=CKV_AWS_109: Does not apply here because KMS key policies only apply to the key itself. (https://docs.bridgecrew.io/docs/ensure-iam-policies-do-not-allow-permissions-management-resource-exposure-without-constraint)
  #checkov:skip=CKV_AWS_356: ignoring asterisk for policies
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid = "Allow SNS to use the key"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
    ]

    resources = [
      "*",
    ]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

  }

  statement {
    sid = "Allow AWS Backup to use the key"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
    ]

    resources = [
      "*",
    ]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

  }
}

data "aws_iam_policy_document" "backup_notifications" {
  #checkov:skip=CKV_AWS_356: ignoring asterisk for policies
  policy_id = "aws_backup_${var.env}"

  statement {
    sid = "aws_backup_${var.env}"
    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_lambda_permission" "with_sns" {
  count         = var.alarm_lambda_arn != "" ? 1 : 0
  statement_id  = "allow_backup_${var.env}"
  action        = "lambda:InvokeFunction"
  function_name = var.alarm_lambda_arn
  principal     = "sns.amazonaws.com"
  source_arn    = module.sns_topic.sns_topic_arn
}

resource "aws_kms_key" "this" {
  description             = "KMS key is used to encrypt this sns topic"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms.json
}

resource "aws_kms_alias" "backup_sns" {
  name          = "alias/aws_backup-sns-${var.env}"
  target_key_id = aws_kms_key.this.arn
}

module "sns_topic" {
  #checkov:skip=CKV_TF_1: https://github.com/bridgecrewio/checkov/issues/5286
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 6.1"


  name              = "backups_${var.env}"
  display_name      = "Backups in ${var.env}"
  kms_master_key_id = aws_kms_key.this.arn
  policy            = data.aws_iam_policy_document.backup_notifications.json
}

resource "aws_sns_topic_subscription" "lambda" {
  count         = var.alarm_lambda_arn != "" ? 1 : 0
  topic_arn     = module.sns_topic.sns_topic_arn
  protocol      = "lambda"
  endpoint      = var.alarm_lambda_arn
  filter_policy = local.filter_completed_backups
}

resource "aws_sns_topic_subscription" "email" {
  for_each      = length(var.alarm_email_addresses) > 0 ? toset(var.alarm_email_addresses) : toset([])
  topic_arn     = module.sns_topic.sns_topic_arn
  protocol      = "email"
  endpoint      = each.key
  filter_policy = local.filter_completed_backups
}

locals {
  filter_completed_backups = <<EOT
  {
      "State": [
        {
          "anything-but": "COMPLETED"
        }
      ]
  }
EOT
}

resource "aws_backup_vault_notifications" "this" {
  count             = var.enable_sns_notifications ? 1 : 0
  backup_vault_name = local.vault_name
  sns_topic_arn     = module.sns_topic.sns_topic_arn
  backup_vault_events = [
    "BACKUP_JOB_COMPLETED", # filter successful backups on sns subscription!
    "RESTORE_JOB_STARTED", "RESTORE_JOB_COMPLETED",
    "S3_BACKUP_OBJECT_FAILED", "S3_RESTORE_OBJECT_FAILED"
  ]
}
