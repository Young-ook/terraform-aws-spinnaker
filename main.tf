### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  aurora_enabled = try(var.features.aurora.enabled, false) ? true : false
  s3_enabled     = try(var.features.s3.enabled, false) ? true : false
  spinnaker_storage = local.s3_enabled ? {
    "minio.enabled" = "false"
    "s3.enabled"    = "true"
    "s3.bucket"     = module.s3.bucket.id
    "s3.region"     = module.aws.region.name
  } : {}
}

### application/kubernetes
module "eks" {
  source              = "Young-ook/eks/aws"
  version             = "1.7.5"
  name                = local.name
  tags                = var.tags
  subnets             = try(var.subnets, null)
  enable_ssm          = try(var.features.eks.ssm_enabled, local.default_eks_cluster["ssm_enabled"])
  kubernetes_version  = try(var.features.eks.version, local.default_eks_cluster["version"])
  managed_node_groups = [local.default_eks_node_group]
  policy_arns = flatten(concat([
    aws_iam_policy.ec2-read.arn,
    aws_iam_policy.rosco-bake.arn,
    aws_iam_policy.spin-assume.*.arn,
    var.kubernetes_policy_arns,
    ],
    local.s3_enabled ? [
      module.s3["enabled"].policy_arns.read,
      module.s3["enabled"].policy_arns.write,
    ] : []
  ))
}

### database/aurora
module "rds" {
  for_each         = local.aurora_enabled ? toset(["enabled"]) : []
  source           = "Young-ook/aurora/aws"
  version          = "2.0.0"
  name             = local.name
  vpc              = try(var.vpc, null)
  subnets          = try(var.subnets, null)
  cidrs            = try(var.cidrs, [])
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

### security/policy
resource "aws_iam_policy" "rosco-bake" {
  name = format("%s-bake", local.name)
  policy = jsonencode({
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
        "ec2:DescribeImageAttribute",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeRegions",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSubnets",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
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
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "ec2-read" {
  name = format("%s-ec2-read", local.name)
  policy = jsonencode({
    Statement = [{
      Action   = "ec2:Describe*"
      Effect   = "Allow"
      Resource = ["*"]
    }]
    Version = "2012-10-17"
  })
}

# assume to cross account spinnaker-managed role
resource "aws_iam_policy" "spin-assume" {
  count = var.assume_role_arn != null ? ((length(var.assume_role_arn) > 0) ? 1 : 0) : 0
  name  = format("%s-assume", local.name)
  policy = jsonencode({
    Statement = [{
      Action   = "sts:AssumeRole"
      Effect   = "Allow"
      Resource = var.assume_role_arn
    }]
    Version = "2012-10-17"
  })
}

### helming!!!

provider "helm" {
  alias = "spinnaker"
  kubernetes {
    host                   = module.eks.helmconfig.host
    token                  = module.eks.helmconfig.token
    cluster_ca_certificate = base64decode(module.eks.helmconfig.ca)
  }
}

resource "helm_release" "spinnaker" {
  depends_on        = [module.eks]
  provider          = helm.spinnaker
  name              = lookup(var.helm, "name", local.default_helm_config["name"])
  chart             = lookup(var.helm, "chart", local.default_helm_config["chart"])
  repository        = lookup(var.helm, "repository", local.default_helm_config["repository"])
  namespace         = lookup(var.helm, "namespace", local.default_helm_config["namespace"])
  timeout           = lookup(var.helm, "timeout", local.default_helm_config["timeout"])
  version           = lookup(var.helm, "version", null)
  dependency_update = lookup(var.helm, "dependency_update", local.default_helm_config["dependency_update"])
  cleanup_on_fail   = lookup(var.helm, "cleanup_on_fail", local.default_helm_config["cleanup_on_fail"])
  create_namespace  = true

  # value block with custom values to be merged with the values yaml
  dynamic "set" {
    for_each = merge(local.spinnaker_storage, lookup(var.helm, "vars", {}))
    content {
      name  = set.key
      value = set.value
    }
  }
}
