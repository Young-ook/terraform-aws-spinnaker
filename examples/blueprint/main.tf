### Spinnaker Blueprint

provider "aws" {
  region = var.aws_region
}

### network
module "spinnaker-aware-aws-vpc" {
  source     = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  version    = "3.0.0"
  name       = var.name
  stack      = "preprod"
  tags       = var.tags
  azs        = var.azs
  cidr       = var.cidr
  enable_igw = true
  enable_ngw = true
  single_ngw = true
}

### platform/spinnaker
module "spinnaker" {
  source  = "Young-ook/spinnaker/aws"
  version = "3.0.0"
  name    = var.name
  tags    = var.tags
  features = {
    #    aurora = { enabled = true }
    #    s3 = { enabled = true }
    eks = {
      ssm_enabled = true
      version     = var.kubernetes_version
    }
    vpc = {
      id      = module.spinnaker-aware-aws-vpc.vpc.id
      subnets = values(module.spinnaker-aware-aws-vpc.subnets["private"])
      cidrs   = [module.spinnaker-aware-aws-vpc.vpc.cidr_block]
    }
  }
}
