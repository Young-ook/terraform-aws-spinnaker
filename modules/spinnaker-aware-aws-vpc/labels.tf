# frigga naming
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "2.3.5"
  name    = var.name
  stack   = var.stack
  detail  = var.detail
  petname = false
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
