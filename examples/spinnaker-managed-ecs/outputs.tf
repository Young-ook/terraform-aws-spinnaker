output "ecs-ec2" {
  value       = module.spinnaker-managed-ecs-ec2.cluster
  description = "The generated AWS ECS cluster"
}

output "ecs-fargate" {
  value       = module.spinnaker-managed-ecs-fargate.cluster
  description = "The generated AWS ECS cluster"
}
