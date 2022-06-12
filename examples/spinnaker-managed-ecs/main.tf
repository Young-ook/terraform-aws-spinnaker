terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# spinnaker managed ecs
module "spinnaker-managed-ecs-ec2" {
  source                     = "Young-ook/spinnaker/aws//modules/spinnaker-managed-ecs"
  version                    = "2.3.2"
  name                       = var.name
  stack                      = var.stack
  detail                     = var.detail
  tags                       = var.tags
  container_insights_enabled = var.container_insights_enabled
  termination_protection     = var.termination_protection
  node_groups                = var.node_groups
}

module "spinnaker-managed-ecs-fargate" {
  source                     = "Young-ook/spinnaker/aws//modules/spinnaker-managed-ecs"
  version                    = "2.3.2"
  name                       = var.name
  stack                      = var.stack
  detail                     = var.detail
  tags                       = var.tags
  container_insights_enabled = var.container_insights_enabled
}
