name   = "vpc"
stack  = "dev"
detail = "tc2"
tags = {
  env  = "dev"
  test = "tc2"
}
aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr       = "10.1.0.0/16"
single_ngw = false
