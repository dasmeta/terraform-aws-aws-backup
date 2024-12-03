variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "region" {
  description = "The region where resources should be managed."
  type        = string
  default     = "eu-central-1"
}

variable "backup_retention_days" {
  description = "Number of days recovery points should be kept."
  type        = number
  default     = 7
}

variable "enable_sns_notifications" {
  description = "Create an SNS topic where backup notifications go"
  type        = bool
  default     = true
}

variable "alarm_lambda_arn" {
  description = "ARN of a lambda function that should be subscribed to monitoring notifications"
  type        = string
  default     = ""
}

variable "alarm_email_addresses" {
  description = "E-Mail addresses that should be subscribed to monitoring notifications"
  type        = list(string)
  default     = []
}

variable "backup_schedule" {
  description = "Schedule of aws backup plan"
  type        = string
  default     = "cron(0 1 * * ? *)"
}

variable "enable_continuous_backup" {
  description = "Flag to enable continuos backup"
  type        = bool
  default     = false
}

variable "backup_plan_name" {
  description = "Initial part of the plan name to which will be appended the env"
  type        = string
  default     = ""
}

variable "plan_selection_tag" {
  description = "Resource selection for the plan"
  type        = list(map)
  default = [
    {
      key   = ""
      value = ""
    }
  ]
}

variable "rules" {
  description = "List of rules to attach to the plan"
  type        = list(map)
  default = [
    {
      name              = "daily"
      schedule          = "cron(0 12 * * ? *)"
      continuous_backup = true
      vault             = "Backup"

      recovery_point_tags = {
        Environment = "dev"
        Plan        = "plan name"
      }
    }
  ]
}
