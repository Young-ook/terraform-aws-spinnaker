data "aws_partition" "current" {}

locals {
  default-tags = merge(
    { "terraform.io" = "managed" },
  )
}
