## managed continuous integration service

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_codebuild_project" "cb" {
  name          = format("%s", local.name)
  tags          = merge(local.default-tags, var.tags)
  description   = "CodeBuild project"
  build_timeout = "5"
  service_role  = aws_iam_role.cb.arn

  artifacts {
    type                = lookup(var.artifact_config, "type", "NO_ARTIFACTS")
    location            = lookup(var.artifact_config, "location", null)
    encryption_disabled = lookup(var.artifact_config, "encryption_disabled", false)
  }

  environment {
    type                        = lookup(var.environment_config, "type", local.default_build_environment["type"])
    image                       = lookup(var.environment_config, "image", local.default_build_environment["image"])
    compute_type                = lookup(var.environment_config, "compute_type", local.default_build_environment["compute_type"])
    image_pull_credentials_type = lookup(var.environment_config, "image_pull_credentials_type", local.default_build_environment["image_pull_credentials_type"])
    privileged_mode             = lookup(var.environment_config, "privileged_mode", local.default_build_environment["privileged_mode"])

    dynamic "environment_variable" {
      for_each = lookup(var.environment_config, "environment_variables", {})
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source {
    type            = lookup(var.source_config, "type", local.default_source_config["type"])
    location        = lookup(var.source_config, "location", local.default_source_config["location"])
    buildspec       = lookup(var.source_config, "buildspec", local.default_source_config["buildspec"])
    git_clone_depth = lookup(var.source_config, "git_clone_depth", 1)
  }
  source_version = lookup(var.source_config, "version", local.default_source_config["version"])

  dynamic "logs_config" {
    for_each = var.log_config != null ? var.log_config : {}
    content {
      dynamic "cloudwatch_logs" {
        for_each = logs_config.key == "cloudwatch_logs" ? var.log_config : {}
        content {
          status      = lookup(cloudwatch_logs.value, "status", null)
          group_name  = lookup(cloudwatch_logs.value, "group_name", null)
          stream_name = lookup(cloudwatch_logs.value, "stream_name", null)
        }
      }

      dynamic "s3_logs" {
        for_each = logs_config.key == "s3_logs" ? var.log_config : {}
        content {
          status              = lookup(s3_logs.value, "status", null)
          location            = lookup(s3_logs.value, "location", null)
          encryption_disabled = lookup(s3_logs.value, "encryption_disabled", null)
        }
      }
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc != null ? var.vpc : {}
    content {
      vpc_id             = lookup(vpc_config.value, "vpc_id", null)
      subnets            = lookup(vpc_config.value, "subnets", null)
      security_group_ids = lookup(vpc_config.value, "security_group_ids", null)
    }
  }
}

# security/policy
resource "aws_iam_role" "cb" {
  name = format("%s-codebuild", local.name)
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("codebuild.%s", data.aws_partition.current.dns_suffix)]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "cb" {
  name        = format("%s-codebuild", local.name)
  description = format("Allow access to ECR and S3 for build process")
  path        = "/"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = [format("arn:${data.aws_partition.current.partition}:logs:*:*:*")]
      },
      {
        Action = [
          "ecr:GetAuthorizationToken", "ssm:GetParameters",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        "Action" = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ],
        "Effect"   = "Allow",
        "Resource" = "*"
      },
      {
        "Action" = [
          "ec2:CreateNetworkInterfacePermission"
        ],
        "Effect" = "Allow",
        Resource = [format("arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*")]
        "Condition" = {
          "StringEquals" = {
            "ec2:AuthorizedService" = "codebuild.amazonaws.com"
          }
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "cb" {
  policy_arn = aws_iam_policy.cb.arn
  role       = aws_iam_role.cb.name
}

resource "aws_iam_role_policy_attachment" "extra" {
  for_each   = { for key, val in var.policy_arns : key => val }
  policy_arn = each.value
  role       = aws_iam_role.cb.name
}
