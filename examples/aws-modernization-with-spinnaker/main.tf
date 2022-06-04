### frigga naming
module "frigga" {
  source = "Young-ook/spinnaker/aws//modules/frigga"
  name   = var.name
  stack  = var.stack
  detail = var.detail
}

### foundation
module "foundation" {
  source             = "./foundation"
  name               = module.frigga.name
  azs                = var.azs
  tags               = var.tags
  kubernetes_version = var.kubernetes_version
}

### platform
module "platform" {
  source             = "./platform"
  name               = module.frigga.name
  tags               = var.tags
  aws_region         = var.aws_region
  azs                = var.azs
  vpc                = module.foundation.vpc
  eks                = module.foundation.eks
  spinnaker_version  = var.spinnaker_version
  kubernetes_version = var.kubernetes_version
}
