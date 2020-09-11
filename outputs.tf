# output variables 

output "name" {
  value       = local.name
  description = "The name of eks cluster to run spinnaker pods"
}

output "endpoint" {
  value       = module.eks.cluster.endpoint
  description = "The enpoint of eks cluster"
}

output "role_arn" {
  value       = module.eks.role.arn
  description = "The generated role ARN of eks node group"
}

output "bucket_name" {
  value       = aws_s3_bucket.storage.id
  description = "The name of s3 bucket to store pipelines and applications of spinnaker"
}

output "artifact_repository" {
  value       = aws_s3_bucket.artifact.id
  description = "The S3 path for artifact repository/storage"
}

output "artifact_write_policy_arn" {
  value       = aws_iam_policy.artifact-write.arn
  description = "The policy ARN to allow access to artifact bucket"
}

output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The Id. of new VPC"
}

output "public_subnets" {
  value       = aws_subnet.public.*.id
  description = "The Id. list of generated public subnets"
}

output "private_subnets" {
  value       = aws_subnet.private.*.id
  description = "The Id. list of generated private subnets"
}

output "db_endpoint" {
  value       = module.rds.endpoint
  description = "The enpoint of aurora mysql cluster"
}

output "kubeconfig" {
  value = join(" ", [
    module.eks.kubeconfig,
  ])
  description = "Bash script to update kubeconfig file"
}
