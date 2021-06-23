aws_region = "ap-northeast-2"
name       = "eks"
stack      = "dev"
detail     = "tc1"
tags = {
  env  = "dev"
  test = "tc1"
}
kubernetes_version = "1.20"
managed_node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.medium"
  }
]
