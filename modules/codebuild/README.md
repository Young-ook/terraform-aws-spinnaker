# AWS CodeBuild
[AWS CodeBuild](https://aws.amazon.com/codebuild/) AWS CodeBuild is a fully managed continuous integration service that compiles source code, runs tests, and produces software packages that are ready to deploy. With CodeBuild, you don’t need to provision, manage, and scale your own build servers. This module will create a CodeBuild project for continuous integration stage in the spinnaker pipeline.

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

## Enabling AWS CodeBuild account in spinnaker
After applying this module, you will see CodeBuild project on your AWS environment. And then you can add your CodeBuild project to the spinnaker using Halyard. Setting up AWS CodeBuild as a Continuous Integration (CI) system within Spinnaker allows you to:
- trigger pipelines when an AWS CodeBuild build changes its phase or state
- add an AWS CodeBuild stage to your pipeline
The AWS Codebuild stage requires Spinnaker 1.19 or later.

This is an example code to enable AWS CodeBuild account in the spinnaker.
```
hal config ci codebuild account add aws-ci \
    --account-id '0123456879031' \
    --assume-role role/spinnaker-test-xgsj \
    --region ap-northeast-2
hal config ci codebuild enable
hal deploy apply
```
**[Important]** Don't forget only one region is allowed for current CodeBuild(CI) configuration.

For more information, please refer to [this](https://spinnaker.io/setup/ci/codebuild/).
