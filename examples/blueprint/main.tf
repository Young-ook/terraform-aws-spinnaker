### Spinnaker Blueprint

provider "aws" {
  region = var.aws_region
}

### network
module "spinnaker-aware-aws-vpc" {
  source              = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  version             = "2.3.6"
  name                = var.name
  stack               = var.stack
  detail              = var.detail
  tags                = var.tags
  azs                 = var.azs
  cidr                = var.cidr
  vpc_endpoint_config = var.vpc_endpoint_config
  enable_igw          = var.enable_igw
  enable_ngw          = var.enable_ngw
  single_ngw          = var.single_ngw
  enable_vgw          = var.enable_vgw
}

### platform/spinnaker
module "spinnaker" {
  source                 = "Young-ook/spinnaker/aws"
  version                = "2.3.6"
  name                   = var.name
  stack                  = "preprod"
  tags                   = var.tags
  region                 = var.aws_region
  azs                    = var.azs
  cidr                   = var.cidr
  assume_role_arn        = [module.spinnaker-managed-role.role_arn]
  kubernetes_version     = var.kubernetes_version
  kubernetes_policy_arns = [module.artifact.policy_arns["read"]]
  kubernetes_node_groups = [
    {
      name          = "tc1"
      instance_type = "m5.xlarge"
      min_size      = "1"
      max_size      = "3"
      desired_size  = "1"
    }
  ]
  aurora_cluster = {
    engine            = "aurora-mysql"
    version           = "5.7.mysql_aurora.2.07.2"
    port              = "3306"
    backup_retention  = "1"
    apply_immediately = "true"
    cluster_parameters = {
      character_set_server = "utf8"
      character_set_client = "utf8"
    }
  }
  aurora_instances = [
    {
      instance_type = "db.t3.medium"
    }
  ]
  s3_bucket = {
    force_destroy = true
  }
  helm = {
    vars = {
      "halyard.spinnakerVersion" = "1.27.0"
      "halyard.image.tag"        = "1.44.0"
    }
  }
}

### environment/preprod
module "spinnaker-managed" {
  source           = "Young-ook/spinnaker/aws//modules/spinnaker-managed-aws"
  version          = "2.3.6"
  name             = "devops"
  stack            = "preprod"
  trusted_role_arn = [module.spinnaker.role.arn]
}
