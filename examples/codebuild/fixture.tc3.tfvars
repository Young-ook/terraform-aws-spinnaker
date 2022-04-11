name   = "codebuild"
stack  = "dev"
detail = "tc3"
tags = {
  env  = "dev"
  test = "tc3"
}
aws_region = "ap-northeast-2"
project_config = {
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
}
