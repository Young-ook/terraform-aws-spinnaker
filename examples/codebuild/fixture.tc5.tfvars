name   = "codebuild"
stack  = "dev"
detail = "tc4"
tags = {
  env         = "dev"
  test        = "tc4"
  default_vpc = false
}
aws_region      = "us-east-2"
azs             = ["us-east-2a", "us-east-2b", ]
use_default_vpc = false
project = {
  source = {
    type = "CODEPIPELINE"
  }
  environment = {
    environment_variables = {
      HELLO = "yyo"
    }
  }
  artifact = {
    type = "CODEPIPELINE"
  }
}
