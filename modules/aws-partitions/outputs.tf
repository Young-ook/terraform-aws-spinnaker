data "aws_partition" "current" {}

output "partition" {
  description = "The attribute map of current AWS partition"
  value       = data.aws_partition.current
}

data "aws_region" "current" {}

output "region" {
  description = "The attribute map of current AWS region"
  value       = data.aws_region.current
}

data "aws_caller_identity" "current" {}

output "caller" {
  description = "The attribute map of current AWS API caller"
  value       = data.aws_caller_identity.current
}
