locals {
  default_source_config = {
    type      = "GITHUB"
    location  = "https://github.com/aws-samples/aws-codebuild-samples.git"
    buildspec = "buildspec.yml"
    version   = "master"
  }
  default_build_environment = {
    type                        = "LINUX_CONTAINER"
    image                       = "aws/codebuild/standard:2.0"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "false"
  }
}
