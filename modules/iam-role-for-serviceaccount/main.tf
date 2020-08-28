locals {
  oidc_fully_qualified_subjects = format("system:serviceaccount:%s:%s", var.namespace, var.serviceaccount)
}

# security/policy
resource "aws_iam_role" "irsa" {
  name = format("%s", local.name)
  path = "/"
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_arn
      }
      Condition = {
        StringEquals = {
          format("%s:sub", var.oidc_url) = local.oidc_fully_qualified_subjects
        }
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each   = toset(var.policy_arns)
  policy_arn = each.value
  role       = aws_iam_role.irsa.name
}
