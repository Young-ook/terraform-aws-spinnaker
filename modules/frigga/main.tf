# name and description
# frigga naming rule
resource "random_string" "suffix" {
  length  = 5
  upper   = false
  lower   = true
  numeric = false
  special = false
}

resource "random_pet" "name" {
  length    = 1
  separator = "-"
}

locals {
  suffix      = var.petname ? random_string.suffix.result : ""
  frigga-name = substr(join("-", compact([(var.name == null || var.name == "" ? random_pet.name.id : var.name), var.stack, var.detail, local.suffix])), 0, var.max_length)
  name-tag    = { "Name" = local.frigga-name }
}
