# name and description
# frigga naming rule
resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  suffix   = var.petname ? random_string.suffix.result : ""
  name     = join("-", compact([var.name, var.stack, var.detail, local.suffix]))
  name-tag = { "Name" = local.name }
}
