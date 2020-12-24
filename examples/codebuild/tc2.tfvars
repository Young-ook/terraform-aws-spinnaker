name   = "codebuild"
stack  = "dev"
detail = "tc2"
tags = {
  env  = "dev"
  test = "tc2"
}
aws_region = "ap-northeast-2"
environment_config = {
  environment_variables = {
    HELLO = "yyo"
  }
}
