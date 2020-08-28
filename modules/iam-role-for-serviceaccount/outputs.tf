output "name" {
  value       = aws_iam_role.irsa.name
  description = "The name of generated IAM role"
}

output "arn" {
  value       = aws_iam_role.irsa.arn
  description = "The ARN of generated IAM role"
}

output "cli" {
  value = join(" ", [
    format("kubectl -n %s create sa %s", var.namespace, var.serviceaccount),
    "&&",
    format("kubectl -n %s annotate sa %s %s",
      var.namespace,
      var.serviceaccount,
      join("=", ["eks.amazonaws.com/role-arn", aws_iam_role.irsa.arn])
    ),
  ])
  description = "The kubernetes configuration file for creating IAM role with service account"
}
