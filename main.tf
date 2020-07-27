# Use this data source to lookup information about the current AWS partition in which Terraform is working.
data "aws_partition" "current" {}

# name and description
locals {
  name   = join("-", compact([var.name, var.stack, var.detail, local.suffix]))
  suffix = random_string.suffix.result
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  lower   = true
  number  = false
  special = false
}

# vpc tags
locals {
  name-tag               = { "Name" = local.name }
  vpc-name-tag           = { "Name" = join("-", compact([local.name, "vpc"])) }
  igw-name-tag           = { "Name" = join("-", compact([local.name, "igw"])) }
  ngw-name-tag           = { "Name" = join("-", compact([local.name, "ngw"])) }
  public-route-name-tag  = { "Name" = join("-", compact([local.name, "public-route"])) }
  private-route-name-tag = { "Name" = join("-", compact([local.name, "private-route"])) }
  private-dns-name-tag   = { "Name" = join("-", compact([local.name, "private-dns"])) }
}

# kubernetes tags
locals {
  vpc-k8s-shared-tag = {
    format("kubernetes.io/cluster/%s", local.name) = "shared"
  }
  vpc-k8s-owned-tag = {
    "key"                 = format("kubernetes.io/cluster/%s", local.name)
    "value"               = "owned"
    "propagate_at_launch" = "true"
  }
}
