# ecr.tf
# elastic container registry

resource "aws_ecr_repository" "docker-repositories" {
  count = "${length(var.ecr_repos)}"

  name = "${join("/", compact(list(
               join("-", compact(list(
                 lookup(var.ecr_repos[count.index], "org", "default"),
                 local.slug,
               ))), 
               lookup(var.ecr_repos[count.index], "repo", "default")
          )))}"

  tags = "${var.tags}"
}
