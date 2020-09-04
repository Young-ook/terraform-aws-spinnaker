### helming!!!

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks.endpoint
    token                  = data.aws_eks_cluster_auth.eks.token
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority.0.data)
    load_config_file       = false
  }
}

resource "helm_release" "spinnaker" {
  name             = lookup(var.helm, "name", local.default_helm_config["name"])
  chart            = lookup(var.helm, "chart", local.default_helm_config["chart"])
  repository       = lookup(var.helm, "repository", local.default_helm_config["repository"])
  namespace        = lookup(var.helm, "namespace", local.default_helm_config["namespace"])
  timeout          = lookup(var.helm, "timeout", local.default_helm_config["timeout"])
  version          = lookup(var.helm, "version", local.default_helm_config["version"])
  values           = [file(lookup(var.helm, "values", local.default_helm_config["values"]))]
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", local.default_helm_config["cleanup_on_fail"])
  create_namespace = true

  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_node_group.ng,
  ]
}
