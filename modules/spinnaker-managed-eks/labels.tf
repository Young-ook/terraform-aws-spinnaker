# Use this data source to lookup information about the current AWS partition in which Terraform is working.
data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# frigga naming 
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "~> 2.0"
  name    = var.name
  stack   = var.stack
  detail  = var.detail
}

locals {
  name = module.frigga.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    local.eks-owned-tag
  )
}

# kubernetes tags
locals {
  eks-shared-tag = {
    format("kubernetes.io/cluster/%s", local.name) = "shared"
  }
  eks-owned-tag = {
    format("kubernetes.io/cluster/%s", local.name) = "owned"
  }
  eks-elb-tag = {
    "kubernetes.io/role/elb" = "1"
  }
  eks-internal-elb-tag = {
    "kubernetes.io/role/internal-elb" = "1"
  }
  eks-autoscaler-tag = {
    format("k8s.io/cluster-autoscaler/%s", local.name) = "owned"
  }
  eks-tag = merge(
    {
      "eks:cluster-name"   = local.name
      "eks:nodegroup-name" = local.name
    },
    local.eks-owned-tag,
    local.eks-autoscaler-tag,
  )
}
