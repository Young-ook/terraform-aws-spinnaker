output "eks" {
  value       = module.spinnaker-managed-eks.cluster
  description = "The generated AWS EKS cluster"
}

output "kubeconfig" {
  value       = module.spinnaker-managed-eks.kubeconfig
  description = "Bash script to update the kubeconfig file for the EKS cluster"
}

output "irsa_cli" {
  value       = module.irsa.cli
  description = "The annotation of IAM role for service account"
}
