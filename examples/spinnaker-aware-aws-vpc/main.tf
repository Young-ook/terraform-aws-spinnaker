terraform {
  required_version = "~> 1.0.0"
}

provider "aws" {
  region = var.aws_region
}

# spinnaker aware amazon vpc
module "spinnaker-aware-aws-vpc" {
  source              = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  version             = ">= 2.0"
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
