### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

### security/policy
resource "aws_iam_role" "spinnaker-managed" {
  name = local.name
  path = "/"
  tags = local.default-tags
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [
          format("ecs.%s", module.aws.partition.dns_suffix),
          format("ecs-tasks.%s", module.aws.partition.dns_suffix),
          format("application-autoscaling.%s", module.aws.partition.dns_suffix)
        ],
        AWS = flatten([
          module.aws.caller.account_id,
          var.trusted_role_arn,
        ])
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "poweruser" {
  name        = format("%s-poweruser", local.name)
  description = "Poweruser Access permission for Spinnaker-Managed-Role"
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17"
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
  })
}

resource "aws_iam_role_policy_attachment" "poweruser" {
  policy_arn = aws_iam_policy.poweruser.arn
  role       = aws_iam_role.spinnaker-managed.id
}

# BaseIAMRole
resource "aws_iam_role" "base-iam" {
  count = var.base_role_enabled ? 1 : 0
  name  = "BaseIAMRole"
  path  = "/"
  tags  = local.default-tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [
          format("ec2.%s", module.aws.partition.dns_suffix),
          format("ecs-tasks.%s", module.aws.partition.dns_suffix)
        ]
      }
    }]
  })
}

resource "aws_iam_instance_profile" "base-iam" {
  count = var.base_role_enabled ? 1 : 0
  name  = "BaseIAMRole"
  role  = aws_iam_role.base-iam[0].name
}
