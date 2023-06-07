### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

### foundation/network
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
  name    = var.name
  tags    = merge(var.tags, (module.eks.tags.shared == null ? {} : module.eks.tags.shared))
  vpc_config = {
    azs         = var.azs
    cidr        = var.cidr
    single_ngw  = true
    subnet_type = "private"
  }
}

### foundation/kubernetes
module "eks" {
  source             = "Young-ook/eks/aws"
  version            = "2.0.3"
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
      desired_size  = 3
      instance_type = "t3.small"
    }
  ]
  policy_arns = [
    format("arn:%s:iam::aws:policy/AWSXRayDaemonWriteAccess", module.aws.partition.partition),
    format("arn:%s:iam::aws:policy/AWSAppMeshEnvoyAccess", module.aws.partition.partition),
  ]
}

provider "helm" {
  kubernetes {
    host                   = module.eks.kubeauth.host
    token                  = module.eks.kubeauth.token
    cluster_ca_certificate = module.eks.kubeauth.ca
  }
}

### kubernetes-addons
module "base" {
  depends_on = [module.eks]
  source     = "Young-ook/eks/aws//modules/helm-addons"
  version    = "2.0.4"
  tags       = var.tags
  addons = [
    {
      ### for more details, https://cert-manager.io/docs/installation/helm/
      repository       = "https://charts.jetstack.io"
      name             = "cert-manager"
      chart_name       = "cert-manager"
      chart_version    = "v1.11.2"
      namespace        = "cert-manager"
      create_namespace = true
      values = {
        "installCRDs" = "true"
      }
    },
  ]
}

module "awsctl" {
  depends_on = [module.base]
  source     = "Young-ook/eks/aws//modules/helm-addons"
  version    = "2.0.4"
  tags       = var.tags
  addons = [
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "aws-load-balancer-controller"
      chart_name     = "aws-load-balancer-controller"
      namespace      = "kube-system"
      serviceaccount = "aws-load-balancer-controller"
      values = {
        "clusterName"                 = module.eks.cluster.name
        "enableServiceMutatorWebhook" = "false"
      }
      oidc        = module.eks.oidc
      policy_arns = [aws_iam_policy.lbc.arn]
    },
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "aws-cloudwatch-metrics"
      chart_name     = "aws-cloudwatch-metrics"
      namespace      = "kube-system"
      serviceaccount = "aws-cloudwatch-metrics"
      values = {
        "clusterName" = module.eks.cluster.name
      }
      oidc = module.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/CloudWatchAgentServerPolicy", module.aws.partition.partition)
      ]
    },
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "aws-for-fluent-bit"
      chart_name     = "aws-for-fluent-bit"
      namespace      = "kube-system"
      serviceaccount = "aws-for-fluent-bit"
      values = {
        "cloudWatch.enabled"      = true
        "cloudWatch.region"       = module.aws.region.name
        "cloudWatch.logGroupName" = format("/aws/containerinsights/%s/application", module.eks.cluster.name)
        "firehose.enabled"        = false
        "kinesis.enabled"         = false
        "elasticsearch.enabled"   = false
      }
      oidc = module.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/CloudWatchAgentServerPolicy", module.aws.partition.partition)
      ]
    },
    {
      repository     = "${path.module}/charts/"
      name           = "cluster-autoscaler"
      chart_name     = "cluster-autoscaler"
      namespace      = "kube-system"
      serviceaccount = "cluster-autoscaler"
      values = {
        "awsRegion"                 = module.aws.region.name
        "autoDiscovery.clusterName" = module.eks.cluster.name
      }
      oidc        = module.eks.oidc
      policy_arns = [aws_iam_policy.cas.arn]
    },
    {
      repository     = "https://aws.github.io/eks-charts"
      name           = "appmesh-controller"
      chart_name     = "appmesh-controller"
      namespace      = "kube-system"
      serviceaccount = "appmesh-controller"
      values = {
        "region"           = module.aws.region.name
        "tracing.enabled"  = true
        "tracing.provider" = "x-ray"
      }
      oidc = module.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/AWSAppMeshEnvoyAccess", module.aws.partition.partition),
        format("arn:%s:iam::aws:policy/AWSCloudMapFullAccess", module.aws.partition.partition),
        format("arn:%s:iam::aws:policy/AWSXRayDaemonWriteAccess", module.aws.partition.partition),
      ]
    },
  ]
}

resource "aws_iam_policy" "lbc" {
  name        = "aws-loadbalancer-controller"
  tags        = merge({ "terraform.io" = "managed" }, var.tags)
  description = format("Allow aws-load-balancer-controller to manage AWS resources")
  policy      = file("${path.module}/policy.aws-loadbalancer-controller.json")
}

resource "aws_iam_policy" "cas" {
  name        = "cluster-autoscaler"
  tags        = merge({ "terraform.io" = "managed" }, var.tags)
  description = format("Allow cluster-autoscaler to manage AWS resources")
  policy      = file("${path.module}/policy.cluster-autoscaler.json")
}
