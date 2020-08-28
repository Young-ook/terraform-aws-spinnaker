provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.cp.endpoint
    token                  = data.aws_eks_cluster_auth.cp.token
    cluster_ca_certificate = base64decode(aws_eks_cluster.cp.certificate_authority.0.data)
    load_config_file       = false
  }
}

provider "helm" {
  alias = "aws-controller"
  kubernetes {
    host                   = aws_eks_cluster.cp.endpoint
    token                  = data.aws_eks_cluster_auth.cp.token
    cluster_ca_certificate = base64decode(aws_eks_cluster.cp.certificate_authority.0.data)
    load_config_file       = false
  }
}

module "cluster-autoscaler" {
  source = "./modules/cluster-autoscaler"

  providers    = { helm = helm.aws-controller }
  enabled      = (var.node_groups != null ? ((length(var.node_groups) > 0) ? true : false) : false)
  cluster_name = aws_eks_cluster.cp.name
  oidc         = local.oidc
  tags         = var.tags
}

module "alb-ingress" {
  source = "./modules/alb-ingress"

  providers    = { helm = helm.aws-controller }
  enabled      = (var.node_groups != null ? ((length(var.node_groups) > 0) ? true : false) : false)
  cluster_name = aws_eks_cluster.cp.name
  oidc         = local.oidc
  tags         = var.tags
}
