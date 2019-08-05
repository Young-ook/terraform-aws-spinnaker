# elastic container registry

resource "aws_ecr_repository" "ecr-repos" {
  count = length(var.ecr_repos)

  name = join(
    "/",
    compact(
      [
        join(
          "-",
          compact(
            [
              lookup(var.ecr_repos[count.index], "org", "default"),
              local.suffix,
            ],
          ),
        ),
        lookup(var.ecr_repos[count.index], "repo", "default"),
      ],
    ),
  )

  tags = var.tags
}

