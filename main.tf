# name and description

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  lower   = true
  number  = false
  special = false
}

# frigga name
locals {
  name         = join("-", compact([var.name, var.stack, var.detail, local.suffix]))
  cluster-name = local.name
  eks-name     = join("-", compact([local.cluster-name, "eks"]))
  nodes-name   = join("-", compact([local.cluster-name, "nodes"]))
  suffix       = random_string.suffix.result
}

# vpc tags
locals {
  vpc-name-tag           = { "Name" = join("-", compact([local.name, "vpc"])) }
  igw-name-tag           = { "Name" = join("-", compact([local.name, "igw"])) }
  ngw-name-tag           = { "Name" = join("-", compact([local.name, "ngw"])) }
  public-route-name-tag  = { "Name" = join("-", compact([local.name, "public-route"])) }
  private-route-name-tag = { "Name" = join("-", compact([local.name, "private-route"])) }
}

# kubernetes tags
locals {
  eks-name-tag   = { "Name" = local.eks-name }
  nodes-name-tag = { "Name" = local.nodes-name }
  vpc-k8s-shared-tag = {
    "kubernetes.io/cluster/${local.cluster-name}" = "shared"
  }
  vpc-k8s-owned-tag = {
    "key"                 = "kubernetes.io/cluster/${local.cluster-name}"
    "value"               = "owned"
    "propagate_at_launch" = "true"
  }
}

terraform {
  required_version = ">= 0.11.0"
}

