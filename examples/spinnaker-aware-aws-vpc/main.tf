terraform {
  required_version = "~> 0.13.0"
}

provider "aws" {
  region  = var.aws_region
  version = ">= 3.0"
}

# spinnaker aware amazon vpc
module "spinnaker-aware-aws-vpc" {
  source     = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  version    = ">= 2.0"
  name       = var.name
  stack      = var.stack
  detail     = var.detail
  tags       = var.tags
  azs        = var.azs
  cidr       = var.cidr
  enable_igw = var.enable_igw
  enable_ngw = var.enable_ngw
  single_ngw = var.single_ngw
}
