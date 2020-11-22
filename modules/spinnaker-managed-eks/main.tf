module "eks" {
  source                    = "Young-ook/eks/aws"
  version                   = "1.4.3"
  name                      = local.name
  tags                      = var.tags
  subnets                   = var.subnets
  kubernetes_version        = var.kubernetes_version
  enabled_cluster_log_types = var.enabled_cluster_log_types
  node_groups               = var.node_groups
  managed_node_groups       = var.managed_node_groups
}
