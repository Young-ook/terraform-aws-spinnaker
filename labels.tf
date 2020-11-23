data "aws_partition" "current" {}

# frigga naming
module "frigga" {
  source = "Young-ook/spinnaker/aws//modules/frigga"
  name   = var.name
  stack  = var.stack
  detail = var.detail
}

locals {
  name               = module.frigga.name
  artifact-repo-name = join("-", [module.frigga.name, "artifact"])
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}

# user vpc tags
locals {
  vpc-tag = {
    Name = format("%s-vpc", local.name)
  }
  igw-tag = {
    Name = format("%s-igw", local.name)
  }
  ngw-tag = {
    Name = format("%s-ngw", local.name)
  }
  public-route-tag = {
    Name = format("%s-public-route", local.name)
  }
  private-route-tag = {
    Name = format("%s-private-route", local.name)
  }
  private-dns-tag = {
    Name = format("%s-private-dns", local.name)
  }
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
