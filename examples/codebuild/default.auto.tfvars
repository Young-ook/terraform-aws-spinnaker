name   = "codebuild"
stack  = "dev"
detail = "default"
tags = {
  env = "dev"
}
aws_region = "ap-northeast-2"
source_config = {
  type      = "GITHUB"
  location  = "https://github.com/aws-samples/aws-codebuild-samples.git"
  buildspec = "buildspec.yml"
  version   = "master"
}
