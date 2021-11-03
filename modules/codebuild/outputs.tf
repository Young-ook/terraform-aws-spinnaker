# output variables 

output "project" {
  description = "The CodeBuild project attributes"
  value       = aws_codebuild_project.cb
}

output "build" {
  description = "AWS CLI command to start build project"
  value = join(" ", [
    "aws codebuild start-build",
    "--region ${data.aws_region.current.name}",
    "--output text",
    "--project-name ${aws_codebuild_project.cb.id}",
  ])
}
