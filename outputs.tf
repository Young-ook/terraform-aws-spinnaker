# output variables 

output "eks" {
  description = "The EKS cluster attributes"
  value       = module.eks.cluster
}

output "role" {
  description = "The generated role of spinnaker"
  value       = module.eks.role
}

output "bucket" {
  description = "The attributes of generated buckets"
  value = {
    spinnaker = {
      name = module.s3.bucket.id
    }
  }
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
