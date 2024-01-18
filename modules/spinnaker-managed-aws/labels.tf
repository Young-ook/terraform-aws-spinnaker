### frigga name
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "3.0.0"
  name    = var.name
  stack   = var.stack
  detail  = var.detail
}

locals {
  name = module.frigga.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "spinnaker.io" = "managed" },
    { "Name" = local.name },
  )
}
