terraform {
  required_version = "~> 0.13.0"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
}

# spinnaker managed role
module "spinnaker-managed-role" {
  source            = "Young-ook/spinnaker/aws//modules/spinnaker-managed-aws"
  version           = ">= 2.0"
  name              = var.name
  stack             = var.stack
  detail            = var.detail
  trusted_role_arn  = var.trusted_role_arn
  base_role_enabled = true
}
