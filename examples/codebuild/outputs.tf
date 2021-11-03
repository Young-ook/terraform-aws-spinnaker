output "project" {
  description = "The CodeBuild project attributes"
  value       = module.ci.project
}

output "build" {
  description = "AWS CLI command to start build project"
  value       = module.ci.build
}

output "log" {
  description = "Attributes of cloudwatch log group"
  value       = module.logs
}
