terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
  vpc_config = {
    azs         = ["ap-northeast-2a", "ap-northeast-2c", "ap-northeast-2d"]
    cidr        = "10.10.0.0/16"
    subnet_type = "private"
    single_ngw  = true
  }
}

module "main" {
  source                     = "../.."
  name                       = "service"
  stack                      = "stack"
  detail                     = "ecs-fargate"
  tags                       = { test = "spinnaker-managed-ecs-fargate" }
  subnets                    = slice(values(module.vpc.subnets["private"]), 0, 3)
  container_insights_enabled = true
}

output "cluster" {
  description = "The generated AWS ECS cluster"
  value       = module.main.cluster
}

output "features" {
  description = "Features configurations of the AWS ECS cluster"
  value       = module.main.features
}
