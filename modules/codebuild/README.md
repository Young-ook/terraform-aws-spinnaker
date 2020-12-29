# AWS CodeBuild
[AWS CodeBuild](https://aws.amazon.com/codebuild/) AWS CodeBuild is a fully managed continuous integration service that compiles source code, runs tests, and produces software packages that are ready to deploy. With CodeBuild, you don’t need to provision, manage, and scale your own build servers.

* You want to use a CodeBuild project for continuous integration stage in your spinnaker pipeline.

## Quickstart
### Setup
```hcl
module "codebuild" {
  source           = "Young-ook/spinnaker/aws//modules/codebuild"
  version          = ">= 2.0"
  name             = "example"
}
```
Run terraform:
```
terraform init
terraform apply
```

## Spinnaker Integration
After applying this module, you will see CodeBuild project on your AWS environment. And then you can add your CodeBuild project to the spinnaker using Halyard. For more details about codebuild project registration with spinnaker, please visit the [Enable AWS CodeBuild account](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/README.md#enabling-aws-codebuild-account-in-spinnaker).
