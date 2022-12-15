aws_region      = "ap-northeast-2"
azs             = ["ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2d"]
use_default_vpc = true
name            = "ecs"
tags = {
  env = "dev"
}
container_insights_enabled = true
termination_protection     = true
node_groups = [
  {
    name          = "default"
    desired_size  = 1
    min_size      = 1
    max_size      = 3
    instance_type = "m6g.large"
    ami_type      = "AL2_ARM_64"
  }
]
