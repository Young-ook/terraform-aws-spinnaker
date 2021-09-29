module "current" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

### kubernetes

module "eks" {
  source              = "Young-ook/eks/aws"
  version             = "1.4.9"
  name                = local.name
  tags                = var.tags
  subnets             = aws_subnet.private.*.id
  kubernetes_version  = var.kubernetes_version
  managed_node_groups = var.kubernetes_node_groups
  enable_ssm          = true
  policy_arns = flatten([
    aws_iam_policy.ec2-read.arn,
    aws_iam_policy.rosco-bake.arn,
    aws_iam_policy.spin-assume.*.arn,
    module.s3.policy_arns.read,
    module.s3.policy_arns.write,
  ])
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster.name
}

### aurora

module "rds" {
  source           = "Young-ook/aurora/aws"
  version          = "2.0.0"
  name             = local.name
  vpc              = aws_vpc.vpc.id
  subnets          = aws_subnet.private.*.id
  cidrs            = [aws_vpc.vpc.cidr_block]
  aurora_cluster   = var.aurora_cluster
  aurora_instances = var.aurora_instances
}

### s3

module "s3" {
  source          = "./modules/s3"
  name            = local.name
  tags            = var.tags
  lifecycle_rules = []
}

locals {
  keys = ["front50", "kayenta", "halyard", ]
}

resource "aws_s3_bucket_object" "keys" {
  for_each = toset(local.keys)
  bucket   = module.s3.bucket.id
  key      = format("%s/", each.value)
  content  = format("%s/", each.value)
}

# security/policy
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
    host                   = module.eks.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.eks.token
    cluster_ca_certificate = base64decode(module.eks.cluster.certificate_authority.0.data)
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
    for_each = lookup(var.helm, "values", {})
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = {
      "minio.enabled" = "false"
      "s3.enabled"    = "true"
      "s3.bucket"     = module.s3.bucket.id
      "s3.region"     = module.current.region.id
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}

### preuninstall

# cleanup script
resource "local_file" "preuninst" {
  depends_on = [helm_release.spinnaker, module.eks, module.rds, module.s3]
  content = join("\n", [
    "#!/bin/sh",
    "aws eks update-kubeconfig --name ${module.eks.cluster.name} --region ${module.current.region.name} --kubeconfig kubeconfig",
    "kubectl --kubeconfig kubeconfig -n spinnaker delete deploy,svc,sts,job,po --force --all",
    "echo $?",
  ])
  filename        = "${path.module}/preuninst.sh"
  file_permission = "0700"
}

resource "null_resource" "preuninst" {
  depends_on = [local_file.preuninst]
  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/preuninst.sh"
  }
}
