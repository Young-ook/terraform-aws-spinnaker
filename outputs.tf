# output variables 

output "eks" {
  description = "The EKS cluster attributes"
  value       = module.eks.cluster
}

output "role" {
  description = "The IAM role for Spinnaker"
  value       = module.eks.role
}

output "bucket" {
  description = "The S3 bucket attributes"
  value       = local.s3_enabled ? module.s3["enabled"].bucket.id : null
}

output "db_endpoint" {
  description = "The endpoint of aurora mysql cluster"
  value       = module.rds.endpoint
}

output "kubeconfig" {
  description = "Bash script to update kubeconfig file"
  value = join(" ", [
    module.eks.kubeconfig,
  ])
}
