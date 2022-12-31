terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
}

# security/firewall
resource "aws_security_group" "ci" {
  vpc_id = module.vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# cloudwatch logs
module "logs" {
  source  = "Young-ook/eventbridge/aws//modules/logs"
  version = "0.0.7"
  name    = "codebuild-logs"
  log_group = {
    namespace      = "/aws/codebuild"
    retension_days = 3
  }
}

module "main" {
  source = "../.."
  name   = "service"
  stack  = "stack"
  detail = "ci"
  tags   = { test = "spinnaker-managed-eks-default" }
  project = {
    source = {
      type      = "GITHUB"
      location  = "https://github.com/aws-samples/aws-codebuild-samples.git"
      buildspec = "buildspec.yml"
      version   = "master"
    }
    environment = {
      image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
      privileged_mode = true
    }
  }
  log = {
    cloudwatch_logs = {
      group_name = module.logs.log_group.name
    }
  }
  vpc = {
    vpc             = module.vpc.vpc.id
    subnets         = values(module.vpc.subnets["public"])
    security_groups = [aws_security_group.ci.id]
  }
}

output "build" {
  description = "AWS CLI command to start build project"
  value       = module.main.build
}
