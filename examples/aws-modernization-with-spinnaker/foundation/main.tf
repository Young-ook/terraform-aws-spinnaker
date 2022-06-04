### foundation/network
module "vpc" {
  source     = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  name       = var.name
  tags       = merge(var.tags, (module.eks.tags.shared == null ? {} : module.eks.tags.shared))
  azs        = var.azs
  cidr       = var.cidr
  enable_ngw = true
  single_ngw = true
}

### foundation/kubernetes
module "eks" {
  source             = "Young-ook/spinnaker/aws//modules/spinnaker-managed-eks"
  version            = "2.1.15"
  name               = var.name
  tags               = merge(var.tags, { release = "canary" })
  subnets            = values(module.vpc.subnets["private"])
  enable_ssm         = true
  kubernetes_version = var.kubernetes_version
  managed_node_groups = [
    {
      name          = "default"
      min_size      = 1
      max_size      = 9
      desired_size  = 2
      instance_type = "t3.medium"
    }
  ]
  policy_arns = [
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess",
  ]
}

provider "helm" {
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

module "lb-controller" {
  source       = "Young-ook/eks/aws//modules/lb-controller"
  version      = "1.7.5"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = var.tags
}

module "app-mesh" {
  source       = "Young-ook/eks/aws//modules/app-mesh"
  version      = "1.7.5"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = var.tags
  helm = {
    version = "1.3.0"
  }
}

module "container-insights" {
  source       = "Young-ook/eks/aws//modules/container-insights"
  version      = "1.7.5"
  cluster_name = module.eks.cluster.name
  oidc         = module.eks.oidc
  tags         = var.tags
  features = {
    enable_metrics = true
    enable_logs    = true
  }
}
