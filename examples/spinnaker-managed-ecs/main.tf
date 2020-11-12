terraform {
  required_version = "~> 0.13.0"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
}

# spinnaker managed ecs
module "spinnaker-managed-ecs-ec2" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-ecs"
  version = "~> 2.0"

  name                       = var.name
  stack                      = var.stack
  detail                     = var.detail
  tags                       = var.tags
  container_insights_enabled = var.container_insights_enabled
  node_groups                = var.node_groups
}

module "spinnaker-managed-ecs-fargate" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-ecs"
  version = "~> 2.0"

  name                       = var.name
  stack                      = var.stack
  detail                     = var.detail
  tags                       = var.tags
  container_insights_enabled = var.container_insights_enabled
}
