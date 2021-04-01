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
      name = aws_s3_bucket.storage.id
    }
    artifact = {
      name = aws_s3_bucket.artifact.id
      policy_arns = zipmap(
        ["write"],
        [aws_iam_policy.artifact-write.arn]
      )
    }
  }
}

output "vpc" {
  description = "The attributes of the secure vpc"
  value       = aws_vpc.vpc
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

output "uninstall" {
  description = "Bash script to prepare helm chart uninstall"
  value = join(" ", [
    "bash -e",
    format("%s/script/pre-uninstall.sh", path.module),
    "-k kubeconfig",
  ])
}
