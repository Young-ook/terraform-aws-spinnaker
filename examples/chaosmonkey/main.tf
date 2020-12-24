# ChaosMonkey

provider "aws" {
  region              = "ap-northeast-2"
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
}

# ecr
module "chaosmonkey-repo" {
  source = "Young-ook/eks/aws//modules/ecr"
  name   = var.name
  tags   = var.tags
}

# codebuild
module "chaosmonkey-build" {
  source  = "Young-ook/spinnaker/aws//modules/codebuild"
  version = "~> 2.0"
  name    = var.name
  stack   = var.stack
  tags    = var.tags

  source_config = {
    type      = "GITHUB"
    location  = "https://github.com/Young-ook/chaosmonkey.git"
    buildspec = join("/", ["buildspec.yml"])
    version   = "dockerbuild"
  }

  environment_config = {
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode = true
    environment_variables = {
      REPOSITORY_URI = module.chaosmonkey-repo.url
    }
  }

  policy_arns = [
    module.chaosmonkey-repo.policy_arns["read"],
    module.chaosmonkey-repo.policy_arns["write"],
  ]
}
