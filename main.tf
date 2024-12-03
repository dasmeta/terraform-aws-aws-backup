data "aws_caller_identity" "current" {}

resource "aws_kms_key" "backup" {
  description             = "${var.env}: Encrypt backup recovery points"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.backup_kms.json
  enable_key_rotation     = true
}

resource "aws_kms_alias" "backup" {
  name          = "alias/aws_backup-${var.env}"
  target_key_id = aws_kms_key.backup.arn
}

resource "aws_backup_vault" "this" {
  name        = local.vault_name
  kms_key_arn = aws_kms_key.backup.arn

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_backup_plan" "daily" {
  name = "daily-${var.env}"

  rule {
    rule_name                = "daily"
    target_vault_name        = aws_backup_vault.this.name
    schedule                 = var.backup_schedule
    enable_continuous_backup = var.enable_continuous_backup

    lifecycle {
      delete_after = var.backup_retention_days
    }

    recovery_point_tags = {
      Environment = var.env
    }
  }
}

resource "aws_backup_selection" "tagged_daily" {
  name    = "daily-tagged-${var.env}"
  plan_id = aws_backup_plan.daily.id

  # selection rules
  dynamic "selection_tag" {
    for_each = var.plan_selection_tag
    content {
      type  = "STRINGEQUALS"
      key   = selection_tag.value["key"]
      value = selection_tag.value["value"]

    }

  }

  iam_role_arn = aws_iam_role.backup.arn
}
