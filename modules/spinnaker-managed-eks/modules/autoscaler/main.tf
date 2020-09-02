## kubernetes cluster autoscaler

locals {
  namespace      = lookup(var.helm, "namespace", "kube-system")
  serviceaccount = lookup(var.helm, "serviceaccount", "cluster-autoscaler")
  oidc_fully_qualified_subjects = format("system:serviceaccount:%s:%s",
    local.namespace,
    local.serviceaccount
  )
}

# security/policy
resource "aws_iam_role" "autoscaler" {
  count = var.enabled ? 1 : 0
  name  = format("%s-autoscaler", var.cluster_name)
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

resource "aws_iam_role_policy_attachment" "autoscaler" {
  count      = var.enabled ? 1 : 0
  policy_arn = aws_iam_policy.autoscaler[0].arn
  role       = aws_iam_role.autoscaler[0].name
}

resource "aws_iam_policy" "autoscaler" {
  count       = var.enabled ? 1 : 0
  name        = format("%s-autoscaler", var.cluster_name)
  description = format("Allow cluster-autoscaler to manage AWS resources")
  path        = "/"
  policy = jsonencode({
    Statement = [{
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions",
      ]
      Effect   = "Allow"
      Resource = ["*"]
    }]
    Version = "2012-10-17"
  })
}


resource "helm_release" "autoscaler" {
  count           = var.enabled ? 1 : 0
  name            = lookup(var.helm, "name", "eks-as")
  chart           = lookup(var.helm, "chart")
  repository      = lookup(var.helm, "repository")
  namespace       = local.namespace
  cleanup_on_fail = lookup(var.helm, "cleanup_on_fail", true)

  dynamic "set" {
    for_each = {
      "autoDiscovery.clusterName"                                      = var.cluster_name
      "rbac.serviceAccount.name"                                       = local.serviceaccount
      "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.autoscaler[0].arn
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}
