terraform {
  required_version = "~> 0.13.0"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
}

# spinnaker managed ecs
module "spinnaker-managed-ecs-ec2" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-ecs"
  version = "~> 2.0"

  name                       = "example"
  stack                      = "dev"
  detail                     = "module-test-ec2"
  tags                       = { env = "dev" }
  subnets                    = ["subnet-1234567", "subnet-7654321", "subnet-1357353"]
  container_insights_enabled = true
  node_groups = {
    default = {
      min_size      = 1
      max_size      = 3
      desired_size  = 2
      instance_type = "t3.large"
      instances_distribution = {
        on_demand_allocation_strategy            = null
        on_demand_base_capacity                  = null
        on_demand_percentage_above_base_capacity = null
        spot_allocation_strategy                 = "capacity-optimized"
        spot_instance_pools                      = null
        spot_max_price                           = "0.03"
      }
      launch_override = [
        {
          instance_type     = "t3.small"
          weighted_capacity = 3
        },
        {
          instance_type     = "t3.medium"
          weighted_capacity = 2
        }
      ]
    }
  }
}

module "spinnaker-managed-ecs-fargate" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-ecs"
  version = "~> 2.0"

  name                       = "example"
  stack                      = "dev"
  detail                     = "module-test-fargate"
  tags                       = { env = "dev" }
  container_insights_enabled = true
}
