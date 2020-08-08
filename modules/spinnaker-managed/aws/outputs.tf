output "role_id" {
  value       = aws_iam_role.spinnaker-managed.id
  description = "The generated id(name) of spinnaker managed role"
}

output "role_arn" {
  value       = aws_iam_role.spinnaker-managed.arn
  description = "The generated arn of spinnaker managed role"
}
