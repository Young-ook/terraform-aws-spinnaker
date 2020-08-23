output "eks" {
  value       = module.spinnaker-managed-eks.cluster
  description = "The generated AWS EKS cluster"
}
