# output variables 

output "cluster" {
  value       = module.eks.cluster
  description = "The EKS cluster attributes"
}

output "role" {
  value       = module.eks.role
  description = "The generated role of the EKS node group"
}

output "oidc" {
  value       = module.eks.oidc
  description = "The OIDC provider attributes for IAM Role for ServiceAccount"
}

output "tags" {
  value       = module.eks.tags
  description = "The generated tags for EKS integration"
}

output "kubeconfig" {
  value = join(" ", [
    module.eks.kubeconfig,
    "-s true",
  ])
  description = "Bash script to update kubeconfig file"
}

output "kubeauth" {
  description = "The kubernetes cluster authentication information for Kubernetes/Helm providers"
  sensitive   = true
  value       = module.eks.kubeauth
}
