output "spinnaker_managed_role_arn" {
  value       = module.spinnaker-managed-role.role_arn
  description = "The generated ARN from spinnaker managed role module"
}
