output "project" {
  description = "The CodeBuild project attributes"
  value       = module.ci.project
}

output "log" {
  description = "Attributes of cloudwatch log group"
  value       = module.logs
}
