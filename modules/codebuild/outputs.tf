# output variables 

output "project" {
  description = "The CodeBuild project attributes"
  value       = aws_codebuild_project.cb
}

output "build" {
  description = "Bash script to start a build proejct"
  value = join(" ", [
    "bash -e",
    format("%s/script/start-build.sh", path.module),
    format("-r %s", module.aws.region.name),
    format("-n %s", aws_codebuild_project.cb.id),
  ])
}
