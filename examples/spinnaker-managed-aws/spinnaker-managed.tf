# Spinnaker managed IAM Role example

terraform {
  required_version = "~> 0.12.0"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 1.21.0"
}

# spinnaker managed role
module "spinnaker-managed-role" {
  source = "../../modules/spinnaker-managed-aws"

  name              = var.name
  stack             = var.stack
  detail            = var.detail
  trusted_role_arn  = var.trusted_role_arn
  base_role_enabled = true
}
