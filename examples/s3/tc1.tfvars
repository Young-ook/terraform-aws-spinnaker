aws_region    = "ap-northeast-2"
name          = "s3"
stack         = "dev"
detail        = "tc1"
force_destroy = true
versioning    = true
tags = {
  env           = "dev"
  test          = "tc1"
  versioning    = "true"
  force-destroy = "true"
}
