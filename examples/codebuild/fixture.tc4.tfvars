name   = "codebuild"
stack  = "dev"
detail = "tc4"
tags = {
  env         = "dev"
  test        = "tc4"
  default_vpc = false
}
aws_region      = "ap-northeast-2"
azs             = ["ap-northeast-2a", "ap-northeast-2b", ]
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
