# Complete example

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}

provider "aws" {
  alias               = "prod"
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
}

# spinnaker
module "spinnaker" {
  source                 = "Young-ook/spinnaker/aws"
  version                = "~> 2.0"
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
  aurora_instances       = var.aurora_instances
  s3_bucket              = var.s3_bucket
  assume_role_arn        = [module.spinnaker-managed-role.role_arn]
}

# spinnaker managed role
module "spinnaker-managed-role" {
  source           = "Young-ook/spinnaker/aws//modules/spinnaker-managed-aws"
  version          = "~> 2.0"
  providers        = { aws = aws.prod }
  name             = "example"
  stack            = "dev"
  trusted_role_arn = [module.spinnaker.role.arn]
}

# artifact bucket
module "artifact" {
  source        = "../../modules/s3"
  name          = "artifact"
  stack         = var.stack
  detail        = var.detail
  tags          = var.tags
  force_destroy = true
}
