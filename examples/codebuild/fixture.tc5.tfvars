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
source_config = {
  type = "CODEPIPELINE"
}
environment_config = {
  environment_variables = {
    HELLO = "yyo"
  }
}
artifact_config = {
  type = "CODEPIPELINE"
}
