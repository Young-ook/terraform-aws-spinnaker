data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}
