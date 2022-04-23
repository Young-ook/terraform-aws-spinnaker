# CodeBuild

provider "aws" {
  region = var.aws_region
}

# network/vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "> 0.0.6"
  name    = join("-", [var.name, "aws"])
  tags    = var.tags
  vpc_config = var.use_default_vpc ? null : {
    cidr        = "10.10.0.0/16"
    azs         = var.azs
    subnet_type = "isolated"
    single_ngw  = true
  }
}

# security/firewall
resource "aws_security_group" "ci" {
  for_each = toset(var.use_default_vpc ? [] : ["default"])
  name     = join("-", [var.name, "codebuild"])
  vpc_id   = module.vpc.vpc.id
  tags     = var.tags

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# build
module "ci" {
  source  = "Young-ook/spinnaker/aws//modules/codebuild"
  version = "~> 2.0"
  name    = var.name
  stack   = var.stack
  detail  = var.detail
  tags    = var.tags
  project = var.project
  log = {
    cloudwatch_logs = {
      group_name = module.logs.log_group.name
    }
  }
  vpc = var.use_default_vpc ? null : {
    vpc             = module.vpc.vpc.id
    subnets         = values(module.vpc.subnets["private"])
    security_groups = [aws_security_group.ci["default"].id]
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
    retension_days = 3
  }
}
