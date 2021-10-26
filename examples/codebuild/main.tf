# CodeBuild

provider "aws" {
  region = "ap-northeast-2"
}

# codebuild
module "ci" {
  source             = "Young-ook/spinnaker/aws//modules/codebuild"
  version            = "~> 2.0"
  name               = var.name
  stack              = var.stack
  detail             = var.detail
  tags               = var.tags
  source_config      = var.source_config
  environment_config = var.environment_config
  log_config = {
    cloudwatch_logs = {
      group_name = module.logs.log_group.name
    }
  }
  policy_arns = []
}

# cloudwatch logs
module "logs" {
  source  = "Young-ook/lambda/aws//modules/logs"
  version = ">= 0.0.4"
  name    = var.name
  log_config = {
    namespace      = "/aws/codebuild"
    retension_days = 5
  }
}
