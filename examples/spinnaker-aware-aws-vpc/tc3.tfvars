name   = "vpc"
stack  = "dev"
detail = "tc3"
tags = {
  env           = "dev"
  subnet-type   = "private"
  nat-per-az    = "single"
  vpc_endpoints = "default"
  test          = "tc3"
}
aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr       = "10.1.0.0/16"
enable_igw = true
enable_ngw = true
single_ngw = true
