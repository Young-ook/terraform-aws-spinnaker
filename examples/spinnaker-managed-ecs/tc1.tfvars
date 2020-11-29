aws_region = "ap-northeast-2"
azs        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
name       = "ecs-tc1"
tags = {
  env  = "dev"
  test = "tc1"
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
