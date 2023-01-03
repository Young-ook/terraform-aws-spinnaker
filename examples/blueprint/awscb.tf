### pipeline/registry
module "chaosmonkey-repo" {
  source  = "Young-ook/eks/aws//modules/ecr"
  version = "2.0.1"
  name    = var.name
  tags    = var.tags
}

### pipeline/registry
module "artifact" {
  source        = "Young-ook/sagemaker/aws//modules/s3"
  name          = "artifact-preprod"
  tags          = var.tags
  force_destroy = true
}

### pipeline/build
module "chaosmonkey-build" {
  source  = "Young-ook/spinnaker/aws//modules/codebuild"
  version = "2.3.6"
  name    = var.name
  stack   = var.stack
  tags    = var.tags
  project = {
    source_config = {
      type      = "GITHUB"
      location  = "https://github.com/Young-ook/chaosmonkey.git"
      buildspec = join("/", ["buildspec.yml"])
      version   = "dockerbuild"
    }
    environment_config = {
      image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
      privileged_mode = true
      environment_variables = {
        REPOSITORY_URI = module.chaosmonkey-repo.url
      }
    }
  }
  policy_arns = [
    module.chaosmonkey-repo.policy_arns["read"],
    module.chaosmonkey-repo.policy_arns["write"],
  ]
}
