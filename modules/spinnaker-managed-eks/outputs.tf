# output variables 

output "cluster" {
  value       = module.eks.cluster
  description = "The EKS cluster attributes"
}

output "role_arn" {
  value       = module.eks.role.arn
  description = "The generated role ARN of the EKS node group"
}

output "tags" {
  value       = module.eks.tags
  description = "The generated tags for EKS integration"
}

output "oidc_url" {
  value       = module.eks.oidc_url
  description = "The URL on the EKS cluster OIDC issuer"
}

output "oidc_arn" {
  value       = module.eks.oidc_arn
  description = "The ARN of OIDC provider"
}

output "kubeconfig" {
  value = join(" ", [
    module.eks.kubeconfig,
    "-s true",
  ])
  description = "Bash script to update kubeconfig file"
}
