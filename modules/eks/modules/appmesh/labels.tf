data "aws_region" "current" {}

locals {
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}
