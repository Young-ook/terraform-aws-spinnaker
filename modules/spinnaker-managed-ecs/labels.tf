### frigga name
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "2.3.5"
  name    = var.name
  stack   = var.stack
  detail  = var.detail
}

locals {
  name = module.frigga.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "spinnaker.io" = "managed" },
    local.ecs-tag
  )
}

# ecs tags
locals {
  ecs-tag = merge(
    { "ecs:cluster-name" = local.name },
    { "AmazonECSManaged" = "true" },
  )
}
