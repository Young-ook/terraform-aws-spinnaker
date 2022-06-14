aws_region      = "ap-northeast-2"
azs             = ["ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2d"]
use_default_vpc = false
name            = "ecs-tc1"
tags = {
  env                    = "dev"
  test                   = "tc1"
  default_vpc            = "false"
  termination_protection = "false"
}
container_insights_enabled = true
termination_protection     = false
node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.large"
  }
]
