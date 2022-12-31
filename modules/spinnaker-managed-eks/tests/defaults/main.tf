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
  source                    = "../.."
  name                      = "service"
  stack                     = "stack"
  detail                    = "eks-ec2"
  tags                      = { test = "spinnaker-managed-eks-default" }
  subnets                   = values(module.vpc.subnets["public"])
  kubernetes_version        = "1.24"
  enabled_cluster_log_types = ["api", "audit"]
  enable_ssm                = true
  managed_node_groups = [
    {
      name          = "default"
      desired_size  = 1
      instance_type = "t3.large"
    }
  ]
}

output "cluster" {
  description = "The generated AWS EKS cluster"
  value       = module.main.cluster
}
