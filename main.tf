locals {
  aws_enabled    = can(var.features.eks.role_arns) ? ((length(var.features.eks.role_arns) > 0) ? true : false) : false
  aurora_enabled = try(var.features.aurora.enabled, false) ? true : false
  s3_enabled     = try(var.features.s3.enabled, false) ? true : false
  ssm_enabled    = try(var.features.eks.ssm_enabled, false) ? true : false
  spinnaker_storage = local.s3_enabled ? {
    "minio.enabled" = "false"
    "s3.enabled"    = "true"
    "s3.bucket"     = module.s3["enabled"].bucket.id
    "s3.region"     = module.aws.region.name
  } : {}
}

### security/policy
resource "aws_iam_policy" "bake-ami" {
  name = join("-", [local.name, "bake-ami"])
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "iam:PassRole",
        "ec2:AttachVolume",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CopyImage",
        "ec2:CreateImage",
        "ec2:CreateKeypair",
        "ec2:CreateSecurityGroup",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:DeleteSnapshot",
        "ec2:DeleteVolume",
        "ec2:DeregisterImage",
        "ec2:Describe*",
        "ec2:DetachVolume",
        "ec2:GetPasswordData",
        "ec2:ModifyImageAttribute",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifySnapshotAttribute",
        "ec2:RegisterImage",
        "ec2:RunInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances",
        "ec2:RequestSpotInstances",
        "ec2:CancelSpotInstanceRequests",
        "ec2:DescribeSpotInstanceRequests",
        "ec2:DescribeSpotPriceHistory",
      ]
      Effect   = "Allow"
      Resource = ["*"]
    }]
  })
}

### security/policy
### Allow spinnaker to assume cross AWS account iam roles
resource "aws_iam_policy" "assume-roles" {
  for_each = local.aws_enabled ? toset(["enabled"]) : []
  name     = join("-", [local.name, "assume"])
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "sts:AssumeRole"
      Effect   = "Allow"
      Resource = flatten([try(var.features.eks.role_arns, [])])
    }]
  })
}

### security/policy
module "irsa" {
  source         = "Young-ook/eks/aws//modules/irsa"
  version        = "2.0.4"
  tags           = merge(local.default-tags, var.tags)
  name           = "spinnaker"
  namespace      = "spinnaker"
  serviceaccount = "default"
  oidc_url       = module.eks.oidc.url
  oidc_arn       = module.eks.oidc.arn
  policy_arns = flatten(concat([
    aws_iam_policy.bake-ami.arn,
    ],
    local.aws_enabled ? [
      aws_iam_policy.assume-roles["enabled"].arn,
    ] : [],
    local.s3_enabled ? [
      module.s3["enabled"].policy_arns.read,
      module.s3["enabled"].policy_arns.write,
    ] : [],
  ))
}

### application/kubernetes
module "eks" {
  source                    = "Young-ook/eks/aws"
  version                   = "2.0.4"
  name                      = local.name
  tags                      = merge(local.default-tags, var.tags)
  subnets                   = try(var.features.vpc.subnets, [])
  enable_ssm                = try(var.features.eks.ssm_enabled, local.default_eks_cluster["ssm_enabled"])
  enabled_cluster_log_types = try(var.features.eks.cluster_logs, local.default_eks_cluster["cluster_logs"])
  kubernetes_version        = try(var.features.eks.version, local.default_eks_cluster["version"])
  managed_node_groups       = [local.default_eks_node_group]
}

### database/aurora
module "rds" {
  for_each         = local.aurora_enabled ? toset(["enabled"]) : []
  source           = "Young-ook/aurora/aws"
  version          = "2.0.0"
  name             = local.name
  vpc              = try(var.features.vpc.id, null)
  subnets          = try(var.features.vpc.subnets, [])
  cidrs            = try(var.features.vpc.cidrs, [])
  aurora_cluster   = local.default_aurora_cluster
  aurora_instances = [local.default_aurora_instance]
}

### staoge/s3
module "s3" {
  for_each      = local.s3_enabled ? toset(["enabled"]) : []
  source        = "Young-ook/sagemaker/aws//modules/s3"
  version       = "0.3.4"
  name          = local.name
  tags          = var.tags
  force_destroy = try(var.features.s3.force_destroy, local.default_s3_bucket["force_destroy"])
  versioning    = try(var.features.s3.versioning, local.default_s3_bucket["versioning"])
}

### kubernetes-addons
provider "helm" {
  alias = "spinnaker"
  kubernetes {
    host                   = module.eks.kubeauth.host
    token                  = module.eks.kubeauth.token
    cluster_ca_certificate = module.eks.kubeauth.ca
  }
}

module "ctl" {
  depends_on = [module.eks]
  source     = "Young-ook/eks/aws//modules/eks-addons"
  version    = "2.0.4"
  tags       = merge(local.default-tags, var.tags)
  addons = [
    {
      name           = "aws-ebs-csi-driver"
      namespace      = "kube-system"
      serviceaccount = "ebs-csi-controller-sa"
      eks_name       = module.eks.cluster.name
      oidc           = module.eks.oidc
      policy_arns = [
        format("arn:%s:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy", module.aws.partition.partition),
      ]
    },
  ]
}

module "helm" {
  depends_on = [module.ctl]
  providers  = { helm = helm.spinnaker }
  source     = "Young-ook/eks/aws//modules/helm-addons"
  version    = "2.0.6"
  tags       = merge(local.default-tags, var.tags)
  addons = [
    {
      repository     = "https://kubernetes-sigs.github.io/metrics-server/"
      name           = "metrics-server"
      chart_name     = "metrics-server"
      namespace      = "kube-system"
      serviceaccount = "metrics-server"
      values = {
        "args[0]" = "--kubelet-preferred-address-types=InternalIP"
      }
    },
    {
      repository     = "https://prometheus-community.github.io/helm-charts"
      name           = "prometheus"
      chart_name     = "prometheus"
      namespace      = "prometheus"
      serviceaccount = "prometheus"
      values = {
        "alertmanager.persistentVolume.storageClass" = "gp2"
        "server.persistentVolume.storageClass"       = "gp2"
      }
    },
    {
      repository        = local.default_helm["repository"]
      name              = local.default_helm["name"]
      chart_name        = local.default_helm["chart_name"]
      chart_version     = local.default_helm["chart_version"]
      namespace         = local.default_helm["namespace"]
      timeout           = local.default_helm["timeout"]
      dependency_update = local.default_helm["dependency_update"]
      cleanup_on_fail   = local.default_helm["cleanup_on_fail"]
      create_namespace  = true
      values = merge(
        local.spinnaker_storage,
        {
          "minio.enabled"      = local.s3_enabled ? "false" : "true"
          "minio.rootUser"     = "spinnakeradmin"
          "minio.rootPassword" = "spinnakeradmin"
      })
    },
  ]
}
