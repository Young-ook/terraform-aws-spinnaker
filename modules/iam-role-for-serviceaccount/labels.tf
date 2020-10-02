# frigga naming
module "frigga" {
  source = "../frigga"
  name   = var.name
  stack  = var.namespace
  detail = var.serviceaccount
}

locals {
  name = module.frigga.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
