provider "helm" {
  alias = "aws-controller"
  kubernetes {
    host                   = aws_eks_cluster.cp.endpoint
    token                  = data.aws_eks_cluster_auth.cp.token
    cluster_ca_certificate = base64decode(aws_eks_cluster.cp.certificate_authority.0.data)
    load_config_file       = false
  }
}

module "autoscaler" {
  source = "./modules/autoscaler"

  depends_on   = [aws_autoscaling_group.ng]
  providers    = { helm = helm.aws-controller }
  enabled      = (var.node_groups != null ? ((length(var.node_groups) > 0) ? true : false) : false)
  cluster_name = aws_eks_cluster.cp.name
  oidc         = local.oidc
  tags         = var.tags
}

module "albingress" {
  source = "./modules/albingress"

  depends_on   = [aws_autoscaling_group.ng]
  providers    = { helm = helm.aws-controller }
  enabled      = (var.node_groups != null ? ((length(var.node_groups) > 0) ? true : false) : false)
  cluster_name = aws_eks_cluster.cp.name
  oidc         = local.oidc
  tags         = var.tags
}

module "containerinsights" {
  source = "./modules/containerinsights"

  depends_on   = [aws_autoscaling_group.ng]
  providers    = { helm = helm.aws-controller }
  enabled      = (var.node_groups != null ? ((length(var.node_groups) > 0 && var.container_insights_enabled) ? true : false) : false)
  cluster_name = aws_eks_cluster.cp.name
  oidc         = local.oidc
  tags         = var.tags
}
