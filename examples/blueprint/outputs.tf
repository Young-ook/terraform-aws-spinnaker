output "spinnaker" {
  description = "Attributes of generated spinnaker"
  value = {
    artifact_bucket = module.artifact.bucket.id
    kubeconfig      = module.spinnaker.kubeconfig
  }
}

output "account" {
  description = "Spinnaker managed role has PowerUser policy in your AWS account that you want manage by spinnaker"
  value       = module.spinnaker-managed.role_arn
}
