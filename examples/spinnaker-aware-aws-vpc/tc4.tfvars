name   = "vpc"
stack  = "dev"
detail = "tc4"
tags = {
  env           = "dev"
  subnet-type   = "private"
  nat-per-az    = "single"
  vpc_endpoints = "none"
  test          = "tc4"
}
aws_region          = "ap-northeast-2"
azs                 = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr                = "10.1.0.0/16"
vpc_endpoint_config = []
enable_igw          = true
enable_ngw          = true
single_ngw          = true
