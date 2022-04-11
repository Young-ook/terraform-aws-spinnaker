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
    WORLD = "yyo"
  }
}
artifact_config = {
  type                = "S3"
  location            = "s3-bucket-name"
  encryption_disabled = true
}
