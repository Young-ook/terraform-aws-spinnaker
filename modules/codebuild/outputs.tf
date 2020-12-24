# output variables 

output "project" {
  description = "The CodeBuild project attributes"
  value       = aws_codebuild_project.cb
}
