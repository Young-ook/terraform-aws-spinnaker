terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.1"
  name    = var.name
  tags    = var.tags
  vpc_config = var.use_default_vpc ? null : {
    azs         = var.azs
    cidr        = "10.10.0.0/16"
    subnet_type = "private"
    single_ngw  = true
  }
}

# spinnaker managed ecs
module "spinnaker-managed-ecs-ec2" {
  source                     = "Young-ook/spinnaker/aws//modules/spinnaker-managed-ecs"
  version                    = "2.3.3"
  name                       = var.name
  stack                      = var.stack
  detail                     = var.detail
  tags                       = var.tags
  subnets                    = slice(values(module.vpc.subnets[var.use_default_vpc ? "public" : "private"]), 0, 3)
  container_insights_enabled = var.container_insights_enabled
  termination_protection     = var.termination_protection
  node_groups                = var.node_groups
}

module "spinnaker-managed-ecs-fargate" {
  source                     = "Young-ook/spinnaker/aws//modules/spinnaker-managed-ecs"
  version                    = "2.3.3"
  name                       = var.name
  stack                      = var.stack
  detail                     = var.detail
  tags                       = var.tags
  subnets                    = slice(values(module.vpc.subnets[var.use_default_vpc ? "public" : "private"]), 0, 3)
  container_insights_enabled = var.container_insights_enabled
}
