name = "spinnaker"
tags = {
  env = "sandbox"
}
aws_region         = "ap-northeast-2"
azs                = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr               = "10.0.0.0/16"
kubernetes_version = "1.20"
kubernetes_node_groups = [
  {
    name          = "default"
    instance_type = "m5.large"
    min_size      = "1"
    max_size      = "3"
    desired_size  = "2"
  }
]
aurora_cluster   = {}
aurora_instances = []
