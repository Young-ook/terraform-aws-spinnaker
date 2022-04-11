locals {
  default_source_config = {
    # allowed values: BITBUCKET | CODECOMMIT | CODEPIPELINE | GITHUB | GITHUB_ENTERPRISE | NO_SOURCE | S3
    type     = "NO_SOURCE"
    location = null
    version = null
    buildspec = yamlencode({
      version = "0.2"
      phases = {
        build = {
          commands = []
      } }
    })
  }
  default_build_environment = {
    type                        = "LINUX_CONTAINER"
    image                       = "aws/codebuild/standard:2.0"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "false"
  }
  default_artifact = {
    # allowed values : NO_ARTIFACTS | CODEPIPELINE | S3
    type                = "NO_ARTIFACTS"
    location            = null
    encryption_disabled = false
  }
}
