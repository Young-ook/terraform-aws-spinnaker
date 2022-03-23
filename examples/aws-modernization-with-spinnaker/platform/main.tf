locals {
  services  = ["yelbv2", ]
  buildpath = "examples/aws-modernization-with-spinnaker/application"
}

### platform/ecr
module "ecr" {
  for_each     = toset(local.services)
  source       = "Young-ook/eks/aws//modules/ecr"
  name         = each.key
  scan_on_push = false
}

### platform/ci
module "ci" {
  for_each = toset(local.services)
  source   = "Young-ook/spinnaker/aws//modules/codebuild"
  version  = "~> 2.0"
  name     = join("-", [each.key, var.name])
  tags     = var.tags
  environment_config = {
    image           = "aws/codebuild/standard:4.0"
    privileged_mode = true
    environment_variables = {
      ARTIFACT_BUCKET = module.artifact.bucket.id
      REPOSITORY_URI  = module.ecr[each.key].url
      APP_NAME        = join("/", [local.buildpath, each.key])
    }
  }
  source_config = {
    type      = "GITHUB"
    location  = "https://github.com/Young-ook/terraform-aws-spinnaker.git"
    buildspec = join("/", [local.buildpath, each.key, "buildspec.yml"])
    version   = "main"
  }
  policy_arns = [
    module.ecr[each.key].policy_arns["read"],
    module.ecr[each.key].policy_arns["write"],
    module.artifact.policy_arns["write"],
  ]
}

# artifact bucket
module "artifact" {
  source        = "Young-ook/sagemaker/aws//modules/s3"
  version       = "0.0.8"
  name          = join("-", ["artifact", var.name])
  tags          = var.tags
  force_destroy = true
}

### platform/spinnaker
module "spinnaker" {
  source             = "Young-ook/spinnaker/aws"
  version            = "2.2.3"
  name               = "spinnaker"
  tags               = var.tags
  region             = var.aws_region
  azs                = var.azs
  cidr               = var.cidr
  kubernetes_version = var.kubernetes_version
  kubernetes_node_groups = [
    {
      name          = "default"
      min_size      = 1
      max_size      = 2
      desired_size  = 1
      disk_size     = "500"
      instance_type = "m5.xlarge"
    }
  ]
  kubernetes_policy_arns = [
    module.artifact.policy_arns["read"],
  ]
  aurora_cluster = {}
  s3_bucket = {
    force_destroy = true
  }
  assume_role_arn = [
    module.spinnaker-managed.role_arn,
  ]
}

module "spinnaker-managed" {
  source           = "Young-ook/spinnaker/aws//modules/spinnaker-managed-aws"
  version          = "~> 2.0"
  name             = var.name
  trusted_role_arn = [module.spinnaker.role.arn]
}

### platform/fis
resource "aws_cloudwatch_metric_alarm" "disk" {
  alarm_name                = join("-", [var.name, "disk-usage-alarm"])
  alarm_description         = "This metric monitors ec2 disk filesystem usage"
  tags                      = var.tags
  metric_name               = "node_filesystem_utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  namespace                 = "ContainerInsights"
  period                    = 30
  threshold                 = 60
  extended_statistic        = "p90"
  insufficient_data_actions = []

  dimensions = {
    ClusterName = var.eks_kubeconfig["context"]
  }
}

resource "aws_iam_role" "fis-run" {
  name = join("-", [var.name, "fis-run"])
  tags = var.tags
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("fis.%s", module.aws-partitions.partition.dns_suffix)]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "fis-run" {
  policy_arn = format("arn:%s:iam::aws:policy/PowerUserAccess", module.aws-partitions.partition.partition)
  role       = aws_iam_role.fis-run.id
}

### systems manager document for fault injection simulator experiment

resource "aws_ssm_document" "disk-stress" {
  name            = "FIS-Run-Disk-Stress"
  tags            = var.tags
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.module}/templates/disk-stress.yaml")
}
