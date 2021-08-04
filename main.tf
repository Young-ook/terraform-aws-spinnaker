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
}
