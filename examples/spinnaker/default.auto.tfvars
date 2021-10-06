name = "spinnaker"
tags = {
  env = "sandbox"
}
aws_region         = "ap-northeast-2"
azs                = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr               = "10.0.0.0/16"
kubernetes_version = "1.21"
aurora_cluster     = {}
aurora_instances   = []
s3_bucket          = {}
