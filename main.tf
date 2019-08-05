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
  master-name  = join("-", compact([local.cluster-name, "eks"]))
  nodes-name   = join("-", compact([local.cluster-name, "node-pool"]))
  suffix       = random_string.suffix.result
}

# kubernetes tags
locals {
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

