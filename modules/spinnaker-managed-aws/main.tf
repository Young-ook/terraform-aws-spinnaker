# spinnaker managed
resource "aws_iam_role" "spinnaker-managed" {
  name = local.name
  path = "/"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [
          format("ecs.%s", data.aws_partition.current.dns_suffix),
          format("ecs-tasks.%s", data.aws_partition.current.dns_suffix),
          format("application-autoscaling.%s", data.aws_partition.current.dns_suffix)
        ],
        AWS = flatten([
          data.aws_caller_identity.current.account_id,
          var.trusted_role_arn,
        ])
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "poweruser-access" {
  name        = format("%s-poweruser", local.name)
  description = "Poweruser Access permission for Spinnaker-Managed-Role"
  path        = "/"
  policy = jsonencode({
    Statement = [
      {
        "Effect" : "Allow",
        "NotAction" : [
          "iam:*",
          "organizations:*",
          "account:*"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateServiceLinkedRole",
          "iam:DeleteServiceLinkedRole",
          "iam:ListRoles",
          "iam:PassRole",
          "organizations:DescribeOrganization",
          "account:ListRegions"
        ],
        "Resource" : "*"
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "poweruser-accs" {
  policy_arn = aws_iam_policy.poweruser-access.arn
  role       = aws_iam_role.spinnaker-managed.id
}

# BaseIAMRole
resource "aws_iam_role" "base-iam" {
  count = var.base_role_enabled ? 1 : 0
  name  = "BaseIAMRole"
  path  = "/"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [
          format("ec2.%s", data.aws_partition.current.dns_suffix),
          format("ecs-tasks.%s", data.aws_partition.current.dns_suffix)
        ]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_instance_profile" "base-iam" {
  count = var.base_role_enabled ? 1 : 0
  name  = "BaseIAMRole"
  role  = aws_iam_role.base-iam[0].name
}
