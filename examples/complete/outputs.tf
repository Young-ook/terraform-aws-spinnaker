output "eks_endpoint" {
  value       = module.spinnaker.endpoint
  description = "The generated endpoint of eks API server to mamage the cluster from spinnaker module"
}

output "spinnaker_role_arn" {
  value       = module.spinnaker.role_arn
  description = "The generated role ARN of eks node group from spinnaker module"
}

output "spinnaker_managed_role_arn" {
  value       = module.spinnaker-managed-role.role_arn
  description = "The generated arn from spinnaker managed role module"
}
