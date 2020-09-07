# Use this data source to lookup information about the current AWS partition in which Terraform is working.
data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

# frigga naming
module "frigga" {
  source = "Young-ook/spinnaker/aws//modules/frigga"
  name   = var.name
  stack  = var.stack
  detail = var.detail
}

locals {
  name = join("-", [module.frigga.name, "spinnaker-managed"])
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
