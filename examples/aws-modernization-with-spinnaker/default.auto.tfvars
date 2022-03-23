aws_region         = "ap-northeast-2"
azs                = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
kubernetes_version = "1.21"
spinnaker_version  = "1.24.5"
name               = "hello"
tags = {
  owner   = "yourid"
  team    = "devops"
  billing = "prod"
}
