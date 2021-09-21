# output variables

output "bucket" {
  description = "Attributes of the generated S3 bucket"
  value       = aws_s3_bucket.bucket
}

output "policy_arns" {
  description = "A map of IAM polices to allow access this S3 bucket. If you want to make an IAM role or instance-profile has permissions to manage this bucket, please attach the `poliy_arn` of this output on your side."
  value       = zipmap(["read", "write"], [aws_iam_policy.read.arn, aws_iam_policy.write.arn])
}

output "empty" {
  description = "Bash script to empty the S3 bucket"
  value = join(" ", [
    "bash -e",
    format("%s/script/empty.sh", path.module),
    format("-r %s", module.current.region.name),
    format("-b %s", aws_s3_bucket.bucket.id),
  ])
}
