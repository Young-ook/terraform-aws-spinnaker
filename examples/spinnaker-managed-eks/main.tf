terraform {
  required_version = "~> 0.13.0"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
}

# spinnaker managed eks
module "spinnaker-managed-eks" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-eks"
  version = "~> 2.0"

  name                       = "example"
  stack                      = "dev"
  detail                     = "module-test"
  tags                       = { env = "dev" }
  subnets                    = ["replace with your subnet ids"]
  kubernetes_version         = "1.17"
  enabled_cluster_log_types  = ["api", "audit"]
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

module "irsa" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-eks//modules/iam-role-for-serviceaccount"
  version = "~> 2.0"

  namespace      = "default"
  serviceaccount = "irsa-test"
  oidc_url       = module.spinnaker-managed-eks.oidc_url
  oidc_arn       = module.spinnaker-managed-eks.oidc_arn
  policy_arns    = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  tags           = { env = "dev" }
}
