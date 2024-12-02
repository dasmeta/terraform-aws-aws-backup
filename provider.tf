provider "aws" {
  region = var.region
  default_tags {
    tags = {
      environment = var.env
      component   = var.component
    }
  }
}

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      version = "5.78.0"
    }
  }
  cloud {
    organization = "dasmeta"
    workspaces {
      tags = ["component:aws_backup"]
    }
  }
}
