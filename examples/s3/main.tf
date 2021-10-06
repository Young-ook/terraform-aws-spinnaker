# S3 bucket

provider "aws" {
  region = "ap-northeast-2"
}

module "s3" {
  source          = "../../modules/s3"
  name            = var.name
  stack           = var.stack
  detail          = var.detail
  force_destroy   = var.force_destroy
  versioning      = var.versioning
  lifecycle_rules = var.lifecycle_rules
  tags            = var.tags
}
