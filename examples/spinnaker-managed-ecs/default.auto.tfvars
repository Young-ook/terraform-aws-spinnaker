aws_region = "ap-northeast-2"
name       = "ecs"
tags = {
  env = "dev"
}
container_insights_enabled = true
termination_protection     = true
node_groups = [
  {
    name          = "default"
    min_size      = 1
    max_size      = 3
    desired_size  = 1
    instance_type = "t3.large"
  }
]
