# Use this data source to lookup information about the current AWS partition in which Terraform is working.
data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# frigga naming
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "~> 2.0"
  name    = var.namespace
  stack   = var.serviceaccount
}

locals {
  name = module.frigga.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
