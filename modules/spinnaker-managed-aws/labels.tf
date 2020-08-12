# Use this data source to lookup information about the current AWS partition in which Terraform is working.
data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

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
  suffix   = random_string.suffix.result
  name     = join("-", compact([var.name, var.stack, var.detail, local.suffix, "spinnaker-managed"]))
  name-tag = { "Name" = local.name }
}
