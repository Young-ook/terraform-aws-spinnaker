terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
}

module "main" {
  source                     = "../.."
  name                       = "service"
  stack                      = "stack"
  detail                     = "ecs-ec2"
  tags                       = { test = "spinnaker-managed-ecs-default" }
  subnets                    = values(module.vpc.subnets["public"])
  container_insights_enabled = true
  termination_protection     = false
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
}

output "cluster" {
  description = "The generated AWS ECS cluster"
  value       = module.main.cluster
}

output "features" {
  description = "Features configurations of the AWS ECS cluster"
  value       = module.main.features
}
