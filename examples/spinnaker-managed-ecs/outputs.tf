output "ecs-ec2" {
  description = "The generated AWS ECS cluster"
  value       = module.spinnaker-managed-ecs-ec2.cluster
}

output "ecs-ec2-features" {
  description = "Features configurations of the AWS ECS cluster"
  value       = module.spinnaker-managed-ecs-ec2.features
}

output "ecs-fargate" {
  description = "The generated AWS ECS cluster"
  value       = module.spinnaker-managed-ecs-fargate.cluster
}
