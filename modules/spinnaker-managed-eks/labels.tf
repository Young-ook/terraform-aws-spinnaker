# frigga naming
module "frigga" {
  source = "../frigga"
  name   = var.name
  stack  = var.stack
  detail = var.detail
}

locals {
  name = module.frigga.name
}
