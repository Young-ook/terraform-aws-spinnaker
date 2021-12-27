locals {
  subnet_type = (!var.enable_igw && !var.enable_ngw) ? "isolated" : (var.enable_igw && !var.enable_ngw) ? "public" : "private"
}

module "vpc" {
  source  = "Young-ook/sagemaker/aws//modules/vpc"
  version = "0.0.6"
  name    = local.name
  tags    = var.tags
  vpc_config = {
    azs         = var.azs
    cidr        = var.cidr
    single_ngw  = var.single_ngw
    subnet_type = local.subnet_type
  }
  vpce_config = var.vpc_endpoint_config
  vgw_config = {
    enable_vgw = var.enable_vgw
  }
}
