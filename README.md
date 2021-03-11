# Spinnaker
[Spinnaker](https://spinnaker.io/) is an open-source, multi-cloud continuous delivery platform for releasing software changes with high velocity and confidence. This is the terraform module to build and install spinnaker on AWS. This module will create Amazon EKS, Amazon Aurora, Amazon S3 resources for spinnaker and utilise Helm chart to install spinnaker application on kubernetes. And it will also create a VPC to place an EKS and an Aurora cluster for the spinnaker. If you want to know how to use this module, please check below examples for more details.

## Examples
- [Spinnaker](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/spinnaker)
- [CodeBuild](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/codebuild)
- [AWS VPC](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/spinnaker-aware-aws-vpc)
- [Spinnaker managed AWS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/spinnaker-managed-aws)
- [Spinnaker managed ECS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/spinnaker-managed-ecs)
- [Spinnaker managed EKS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/spinnaker-managed-eks)
- [Chaos Monkey](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/chaosmonkey)

## Getting started
### AWS CLI
Follow the official guide to install and configure profiles.
- [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

### Terraform
Infrastructure Engineering team is using terraform to build and manage infrastucure for DevOps. And we have a plan to migrate cloudformation termplate to terraform.

To install Terraform, find the appropriate package (https://www.terraform.io/downloads.html) for your system and download it. Terraform is packaged as a zip archive and distributed as a single binary. Install Terraform by unzipping it and moving it to a directory included in your system's `PATH`.

And there is an another option for easy install. The [tfenv](https://github.com/tfutils/tfenv) is very useful solution.
You can use this utility to make it ease to install and switch terraform binaries in your workspace like below.
```
$ tfenv install 0.12.18
$ tfenv use 0.12.18
```
Also this tool is helpful to upgrade terraform v0.12. It is a major release focused on configuration language improvements and thus includes some changes that you'll need to consider when upgrading. But the version 0.11 and 0.12 are very different. So if some codes are written in older version and others are in 0.12 it would be great for us to have nice tool to support quick switching of version.
```
$ tfenv list
$ tfenv use 0.12.18
$ tfenv use 0.11.14
$ tfenv install latest
$ tfenv use 0.12.18
```

### Setup
```hcl
module "spinnaker" {
  source  = "Young-ook/spinnaker/aws"
  version = "~> 2.0"

  name    = "spinnaker"
  stack   = "test"
  tags    = { env = "test" }
}
```
Run terraform:
```
terraform init
terraform apply
```

### Generate kubernetes config
This terraform module provides users a shell script that extracts the kubeconfig file of the EKS cluster. For more details, please visit the [terraform eks module](
https://github.com/Young-ook/terraform-aws-eks/blob/main/README.md#generate-kubernetes-config).

### Access the spinnaker
```
export KUBECONFIG=<path-to-spinnaker-kubeconfig-file>
kubectl -n spinnaker port-forward svc/spin-deck 9000:9000
```
![Spinnaker](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/images/cluster-management.png)

## Cloud Providers
#### AWS
Users can add AWS account to spinnaker using halyard which is the command-line tool for spinnaker management. To enable AWS account in the spinnaker, please follow the instructions in the [Spinnaker Managed AWS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/spinnaker-managed-aws) example.

#### Amazon ECS
And users can enable ECS account in the spinnaker using halyard. Please follow the instructions in the [Spinnaker Managed ECS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/spinnaker-managed-ecs) example.

#### Amazon EKS
And users can enable Kubernetes account in the spinnaker using halyard. Please follow the instructions in the [Spinnaker Managed EKS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/spinnaker-managed-eks) example.


## Continuous Integration
#### CodeBuild
Users can set up AWS CodeBuild as a Continuous Integration (CI) system within spinnaker for cloud backed build system. For more details about codebuild project registration with spinnaker, please visit the [Enable AWS CodeBuild account](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/codebuild).
