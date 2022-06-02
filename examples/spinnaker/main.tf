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
  source                 = "../../"
  name                   = var.name
  stack                  = var.stack
  detail                 = var.detail
  tags                   = var.tags
  region                 = var.aws_region
  azs                    = var.azs
  cidr                   = var.cidr
  kubernetes_version     = var.kubernetes_version
  kubernetes_node_groups = var.kubernetes_node_groups
  kubernetes_policy_arns = [module.artifact.policy_arns["read"]]
  aurora_cluster         = var.aurora_cluster
  aurora_instances       = var.aurora_instances
  s3_bucket              = var.s3_bucket
  assume_role_arn        = [module.spinnaker-managed-role.role_arn]
  helm = {
    vars = {
      "halyard.spinnakerVersion" = "1.27.0"
    }
  }
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
module "frigga" {
  source = "Young-ook/spinnaker/aws//modules/frigga"
  name   = "artifact"
  stack  = var.stack
  detail = var.detail
}

module "artifact" {
  source        = "Young-ook/sagemaker/aws//modules/s3"
  name          = module.frigga.name
  tags          = var.tags
  force_destroy = true
}
