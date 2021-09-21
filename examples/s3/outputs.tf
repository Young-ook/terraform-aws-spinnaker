output "s3" {
  description = "The attributes of s3 bucket"
  value       = module.s3.bucket
}

output "empty" {
  description = "Bash script to empty the S3 bucket"
  value       = module.s3.empty
}

output "policy_arns" {
  description = "A map of IAM polices to allow access this S3 bucket. If you want to make an IAM role or instance-profile has permissions to manage this bucket, please attach the `poliy_arn` of this output on your side."
  value       = module.s3.policy_arns
}
