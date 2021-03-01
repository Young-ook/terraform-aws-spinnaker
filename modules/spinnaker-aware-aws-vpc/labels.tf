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
    local.vpc-tag
  )
}

# vpc tags
locals {
  vpc-tag = merge(
    { "vpc:name" = local.name },
  )
}
