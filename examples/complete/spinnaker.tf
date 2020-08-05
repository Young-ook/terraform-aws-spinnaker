# Complete example

terraform {
  required_version = "~> 0.12.0"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 1.21.0"
}

provider "aws" {
  alias               = "prod"
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 1.21.0"
}

# spinnaker
module "spinnaker" {
  source  = "Young-ook/spinnaker/aws"
  version = "~> 2.0"

  name                   = var.name
  stack                  = var.stack
  detail                 = var.detail
  tags                   = var.tags
  region                 = var.aws_region
  azs                    = var.azs
  cidr                   = var.cidr
  kubernetes_version     = var.kubernetes_version
  kubernetes_node_groups = var.kubernetes_node_groups
  aurora_cluster         = var.aurora_cluster
  dns_zone               = var.dns_zone
  helm_chart_version     = "2.1.0-rc.1"
  helm_chart_values      = [file(var.helm_chart_values_file)]
  assume_role_arn        = [module.spinnaker-managed-role.role_arn]
}

# spinnaker managed role
module "spinnaker-managed-role" {
  source  = "Young-ook/spinnaker-managed/aws"
  version = "~> 1.0"

  providers        = { aws = aws.prod }
  name             = "test"
  stack            = "prod"
  trusted_role_arn = [module.spinnaker.role_arn]
}
