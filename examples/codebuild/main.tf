# CodeBuild

provider "aws" {
  region              = "ap-northeast-2"
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
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
  policy_arns        = []
}
