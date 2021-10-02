output "spinnaker" {
  description = "Attributes of generated spinnaker"
  value = {
    artifact_bucket = module.artifact.bucket.id
    kubeconfig      = module.spinnaker.kubeconfig
  }
}

output "spinnaker_managed_role_arn" {
  description = "The generated ARN from spinnaker managed role module"
  value       = module.spinnaker-managed-role.role_arn
}
