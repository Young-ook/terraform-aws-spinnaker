resource "helm_release" "containerinsights" {
  count            = ((length(var.node_groups) > 0) && var.container_insights_enabled ? 1 : 0)
  name             = local.name
  chart            = "containerinsights"
  repository       = join("/", [path.module, "charts"])
  version          = "0.1.0"
  namespace        = "amazon-cloudwatch"
  create_namespace = true
  reset_values     = true

  dynamic "set" {
    for_each = {
      "cluster.name"   = aws_eks_cluster.cp.name
      "cluster.region" = data.aws_region.current.name
    }
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [
    aws_eks_cluster.cp,
    aws_iam_policy.logs,
  ]
}
