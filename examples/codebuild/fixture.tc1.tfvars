name   = "codebuild"
stack  = "dev"
detail = "tc1"
tags = {
  env  = "dev"
  test = "tc1"
}
aws_region = "ap-northeast-2"
source_config = {
  type      = "GITHUB"
  location  = "https://github.com/Young-ook/terraform-aws-spinnaker.git"
  buildspec = "buildspec.yml"
  version   = "main"
}
environment_config = {
  image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
  privileged_mode = true
}
