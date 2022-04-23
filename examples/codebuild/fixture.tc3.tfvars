name   = "codebuild"
stack  = "dev"
detail = "tc3"
tags = {
  env  = "dev"
  test = "tc3"
}
aws_region = "ap-northeast-2"
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
