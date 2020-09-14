# frigga naming
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "~> 2.0"
  name    = var.name
  stack   = var.namespace
  detail  = var.serviceaccount
}

locals {
  name = module.frigga.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
