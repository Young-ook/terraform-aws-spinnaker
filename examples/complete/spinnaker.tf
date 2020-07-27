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

  name                    = var.name
  stack                   = var.stack
  detail                  = var.detail
  tags                    = var.tags
  region                  = var.aws_region
  azs                     = var.azs
  cidr                    = var.cidr
  kube_version            = var.kube_version
  kube_node_type          = var.kube_node_type
  kube_node_size          = var.kube_node_size
  kube_node_vol_size      = var.kube_node_vol_size
  mysql_version           = var.mysql_version
  mysql_port              = var.mysql_port
  mysql_node_type         = var.mysql_node_type
  mysql_node_size         = var.mysql_node_size
  mysql_master_user       = var.mysql_master_user
  mysql_db                = var.mysql_db
  mysql_snapshot          = var.mysql_snapshot
  mysql_apply_immediately = var.mysql_apply_immediately
  dns_zone                = var.dns_zone
  helm_chart_version      = "2.1.0-rc.1"
  helm_chart_values       = [file(var.helm_chart_values_file)]
  assume_role_arn         = [module.spinnaker-managed-role.role_arn]
}

# spinnaker managed role
module "spinnaker-managed-role" {
  source  = "Young-ook/spinnaker-managed-role/aws"
  version = "1.0.3"

  providers        = { aws = aws.prod }
  desc             = "preprod"
  trusted_role_arn = [module.spinnaker.role_arn]
}
