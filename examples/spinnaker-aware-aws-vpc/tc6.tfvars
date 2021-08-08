name   = "vpc"
stack  = "dev"
detail = "tc6"
tags = {
  env           = "dev"
  subnet-type   = "isolated"
  vpn-gateway   = "enabled"
  vpc_endpoints = "none"
  test          = "tc6"
}
aws_region          = "ap-northeast-2"
azs                 = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr                = "10.1.0.0/16"
enable_igw          = false
enable_ngw          = false
enable_vgw          = true
vpc_endpoint_config = []
