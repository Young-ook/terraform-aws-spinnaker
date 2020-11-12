# Use this data source to lookup information about the current AWS partition in which Terraform is working.
data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# frigga naming
module "frigga" {
  source = "Young-ook/spinnaker/aws//modules/frigga"
  name   = var.name
  stack  = var.stack
  detail = var.detail
}

locals {
  name = module.frigga.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    local.ecs-tag
  )
}

# ecs tags
locals {
  ecs-tag = merge(
    { "ecs:cluster-name" = local.name },
  )
}
