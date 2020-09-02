## kubernetes container-insights

locals {
  namespace      = lookup(var.helm, "namespace", "amazon-cloudwatch")
  serviceaccount = lookup(var.helm, "serviceaccount", "aws-container-insights")
  oidc_fully_qualified_subjects = format("system:serviceaccount:%s:%s",
    local.namespace,
    local.serviceaccount
  )
}

# security/policy
resource "aws_iam_role" "containerinsights" {
  count = var.enabled ? 1 : 0
  name  = format("%s-containerinsights", var.cluster_name)
  path  = "/"
  tags  = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = var.oidc["arn"]
      }
      Condition = {
        StringEquals = { join(":", [var.oidc["url"], "sub"]) = [local.oidc_fully_qualified_subjects] }
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "containerinsights" {
  count       = var.enabled ? 1 : 0
  name        = format("%s-logs", var.cluster_name)
  description = format("Allow cloudwatch-agent to manage AWS CloudWatch logs for ContainerInsights")
  path        = "/"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = [format("arn:${data.aws_partition.current.partition}:logs:*:*:*")]
      },
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "containerinsights" {
  count      = var.enabled ? 1 : 0
  policy_arn = aws_iam_policy.containerinsights[0].arn
  role       = aws_iam_role.containerinsights[0].name
}

resource "helm_release" "containerinsights" {
  count            = var.enabled ? 1 : 0
  name             = lookup(var.helm, "name", "eks-cw")
  chart            = lookup(var.helm, "chart")
  repository       = lookup(var.helm, "repository", join("/", [path.module, "charts"]))
  namespace        = local.namespace
  create_namespace = true
  cleanup_on_fail  = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = {
      "cluster.name"                                              = var.cluster_name
      "cluster.region"                                            = data.aws_region.current.name
      "serviceAccount.name"                                       = local.serviceaccount
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.containerinsights[0].arn
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}
