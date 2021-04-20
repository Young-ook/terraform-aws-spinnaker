output "eks_endpoint" {
  description = "The generated endpoint of eks API server to mamage the cluster from spinnaker module"
  value       = module.spinnaker.eks.endpoint
}

output "spinnaker_role_arn" {
  description = "The generated role ARN of eks node group from spinnaker module"
  value       = module.spinnaker.role.arn
}

output "spinnaker_managed_role_arn" {
  value       = module.spinnaker-managed-role.role_arn
  description = "The generated ARN from spinnaker managed role module"
}

output "artifact_write_policy_arn" {
  description = "Policy ARN created to allow CI tools to upload the artifacts"
  value       = module.spinnaker.bucket.artifact.policy_arns.write
}

output "kubeconfig" {
  description = "Bash script to update the kubeconfig file for the EKS cluster"
  value       = module.spinnaker.kubeconfig
}

output "uninstall" {
  description = "Bash script to prepare helm chart uninstall"
  value       = module.spinnaker.uninstall
}
