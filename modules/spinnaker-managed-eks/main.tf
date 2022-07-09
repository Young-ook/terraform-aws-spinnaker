module "eks" {
  source                    = "Young-ook/eks/aws"
  version                   = "1.7.5"
  name                      = local.name
  tags                      = var.tags
  subnets                   = var.subnets
  kubernetes_version        = var.kubernetes_version
  enabled_cluster_log_types = var.enabled_cluster_log_types
  node_groups               = var.node_groups
  managed_node_groups       = var.managed_node_groups
  policy_arns               = var.policy_arns
  enable_ssm                = var.enable_ssm
}
