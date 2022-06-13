# output variables 

output "cluster" {
  description = "The ECS cluster attributes"
  value       = aws_ecs_cluster.cp
}

output "role_arn" {
  description = "The generated role ARN of the ECS node group"
  value = (local.node_groups_enabled ? zipmap(
    ["name", "arn"],
    [aws_iam_role.ng.0.name, aws_iam_role.ng.0.arn]
  ) : null)
}

output "features" {
  description = "Features configurations for the ECS"
  value = {
    "node_groups_enabled" = local.node_groups_enabled
    "fargate_enabled"     = !local.node_groups_enabled
  }
}
