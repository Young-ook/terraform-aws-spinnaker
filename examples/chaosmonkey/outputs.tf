output "url" {
  description = "A URL of generated ECR repository"
  value       = module.chaosmonkey-repo.url
}

output "policy_arns" {
  description = "A map of IAM polices to allow access this ECR repository. If you want to make an IAM role or instance-profile has permissions to manage this repository, please attach the `poliy_arn` of this output on your side."
  value       = module.chaosmonkey-repo.policy_arns
}
