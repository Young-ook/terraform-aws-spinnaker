# output variables 

output "name" {
  value       = local.name
  description = "The ECS cluster name"
}

output "cluster" {
  value       = aws_ecs_cluster.cp
  description = "The ECS cluster attributes"
}

output "role_arn" {
  value       = aws_iam_role.ng.arn
  description = "The generated role ARN of the ECS node group"
}
