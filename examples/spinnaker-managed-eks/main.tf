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
  kubernetes_version         = "1.17"
  enabled_cluster_log_types  = ["api", "audit"]
  container_insights_enabled = true
  app_mesh_enabled           = true
  node_groups = {
    default = {
      min_size      = 1
      max_size      = 3
      desired_size  = 1
      instance_type = "t3.medium"
      instances_distribution = {
        on_demand_allocation_strategy            = "prioritized"
        on_demand_base_capacity                  = 0
        on_demand_percentage_above_base_capacity = 100
        spot_allocation_strategy                 = "lowest-price"
        spot_instance_pools                      = 2
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
  source  = "Young-ook/spinnaker/aws//modules/iam-role-for-serviceaccount"
  version = "~> 2.0"

  enabled        = false
  namespace      = "default"
  serviceaccount = "irsa-test"
  oidc_url       = module.spinnaker-managed-eks.oidc.url
  oidc_arn       = module.spinnaker-managed-eks.oidc.arn
  policy_arns    = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  tags           = { env = "dev" }
}
