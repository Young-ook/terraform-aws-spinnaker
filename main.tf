### kubernetes

module "eks" {
  source = "./modules/eks"

  name                       = var.name
  stack                      = var.stack
  detail                     = var.detail
  tags                       = var.tags
  subnets                    = aws_subnet.private.*.id
  kubernetes_version         = var.kubernetes_version
  node_groups                = var.kubernetes_node_groups
  enabled_cluster_log_types  = var.enabled_cluster_log_types
  container_insights_enabled = var.container_insights_enabled
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.name
}

### aurora

module "rds" {
  source = "./modules/aurora"

  name             = local.name
  vpc              = aws_vpc.vpc.id
  subnets          = aws_subnet.private.*.id
  cidrs            = [aws_vpc.vpc.cidr_block]
  aurora_cluster   = var.aurora_cluster
  aurora_instances = var.aurora_instances
}

### helming!!!

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.eks.token
    cluster_ca_certificate = base64decode(module.eks.cluster.certificate_authority.0.data)
    load_config_file       = false
  }
}

resource "helm_release" "spinnaker" {
  depends_on       = [module.eks]
  name             = lookup(var.helm, "name", local.default_helm_config["name"])
  chart            = lookup(var.helm, "chart", local.default_helm_config["chart"])
  repository       = lookup(var.helm, "repository", local.default_helm_config["repository"])
  namespace        = lookup(var.helm, "namespace", local.default_helm_config["namespace"])
  timeout          = lookup(var.helm, "timeout", local.default_helm_config["timeout"])
  version          = lookup(var.helm, "version", local.default_helm_config["version"])
  values           = [file(lookup(var.helm, "values", local.default_helm_config["values"]))]
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", local.default_helm_config["cleanup_on_fail"])
  create_namespace = true
}
