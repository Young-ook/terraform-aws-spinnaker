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
  version  = "2.2.3"
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
resource "aws_cloudwatch_metric_alarm" "svc" {
  alarm_name                = join("-", [var.name, "svc", "alarm"])
  alarm_description         = "This metric monitors healty backed pods of a service"
  tags                      = merge(var.tags)
  metric_name               = "service_number_of_running_pods"
  comparison_operator       = "LessThanThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  namespace                 = "ContainerInsights"
  period                    = 10
  threshold                 = 1
  statistic                 = "Average"
  insufficient_data_actions = []
  dimensions = {
    ClusterName = var.eks["cluster"].name
    Namespace   = var.eks["cluster"].name
    Service     = "yelb-ui"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name                = join("-", [var.name, "cpu", "alarm"])
  alarm_description         = "This metric monitors ec2 cpu utilization"
  tags                      = merge(var.tags)
  metric_name               = "node_cpu_utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = 1
  evaluation_periods        = 1
  namespace                 = "ContainerInsights"
  period                    = 30
  threshold                 = 60
  statistic                 = "Average"
  insufficient_data_actions = []
  dimensions = {
    ClusterName = var.eks["cluster"].name
  }
}

module "logs" {
  source  = "Young-ook/lambda/aws//modules/logs"
  version = "0.2.1"
  for_each = { for l in [
    {
      type = "fis"
      log_group = {
        namespace      = "/aws/fis"
        retension_days = 3
      }
    },
  ] : l.type => l }
  name      = join("-", [var.name, each.key])
  log_group = each.value.log_group
}

# drawing lots for choosing a subnet
resource "random_integer" "az" {
  min = 0
  max = length(var.azs) - 1
}

module "awsfis" {
  source  = "Young-ook/fis/aws"
  version = "1.0.1"
  name    = var.name
  tags    = var.tags
  experiments = [
    {
      name     = "terminate-eks-nodes"
      template = "${path.module}/templates/terminate-eks-nodes.tpl"
      params = {
        az        = var.azs[random_integer.az.result]
        vpc       = var.vpc.id
        nodegroup = var.eks["cluster"].data_plane.managed_node_groups.default.arn
        role      = module.awsfis.role["fis"].arn
        logs      = format("%s:*", module.logs["fis"].log_group.arn)
        alarm = jsonencode([
          {
            source = "aws:cloudwatch:alarm"
            value  = aws_cloudwatch_metric_alarm.svc.arn
          },
          {
            source = "aws:cloudwatch:alarm"
            value  = aws_cloudwatch_metric_alarm.cpu.arn
          },
        ])
      }
    },
  ]
}
