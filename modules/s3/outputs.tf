# output variables

output "bucket" {
  description = "Attributes of the generated S3 bucket"
  value       = aws_s3_bucket.bucket
}

output "policy_arns" {
  description = "A map of IAM polices to allow access this S3 bucket. If you want to make an IAM role or instance-profile has permissions to manage this bucket, please attach the `poliy_arn` of this output on your side."
  value       = zipmap(["read", "write"], [aws_iam_policy.read.arn, aws_iam_policy.write.arn])
}
