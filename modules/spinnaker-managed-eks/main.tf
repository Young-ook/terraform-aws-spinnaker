module "eks" {
  source = "Young-ook/spinnaker/aws//modules/eks"

  name                       = var.name
  stack                      = var.stack
  detail                     = var.detail
  tags                       = var.tags
  subnets                    = var.subnets
  kubernetes_version         = var.kubernetes_version
  enabled_cluster_log_types  = var.enabled_cluster_log_types
  container_insights_enabled = var.container_insights_enabled
  node_groups                = var.node_groups
}
