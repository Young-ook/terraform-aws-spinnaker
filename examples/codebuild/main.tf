# CodeBuild

provider "aws" {
  region = "ap-northeast-2"
}

# codebuild
module "ci" {
  source  = "Young-ook/spinnaker/aws//modules/codebuild"
  version = "~> 2.0"
  name    = var.name
  stack   = var.stack
  detail  = var.detail
  tags    = var.tags
  project = {
    artifact    = var.artifact_config
    source      = var.source_config
    environment = var.environment_config
  }
  log = {
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
  log_group = {
    namespace      = "/aws/codebuild"
    retension_days = 5
  }
}
