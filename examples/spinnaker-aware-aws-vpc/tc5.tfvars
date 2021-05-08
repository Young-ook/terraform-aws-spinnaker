name   = "vpc"
stack  = "dev"
detail = "tc5"
tags = {
  env           = "dev"
  subnet-type   = "isolated"
  nat-per-az    = "none"
  vpc_endpoints = "custom"
  test          = "tc5"
}
aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr       = "10.1.0.0/16"
vpc_endpoint_config = [
  {
    service             = "s3"
    type                = "Interface"
    private_dns_enabled = false
  },
  {
    service             = "sts"
    type                = "Interface"
    private_dns_enabled = true
  },
]
enable_igw = false
enable_ngw = false
