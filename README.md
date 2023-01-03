# Spinnaker
[Spinnaker](https://spinnaker.io/) is an open-source, multi-cloud continuous delivery platform for releasing software changes with high velocity and confidence. This is the terraform module to build and install spinnaker on AWS. This module will create Amazon EKS, Amazon Aurora, Amazon S3 resources for spinnaker and utilise Helm chart to install spinnaker application on kubernetes. And it will also create a VPC to place an EKS and an Aurora cluster for the spinnaker. If you want to know how to use this module, please check below examples for more details.

## Examples
- [Spinnaker Blueprint](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/blueprint)
- [AWS Modernization with Spinnaker](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/aws-modernization-with-spinnaker)
- [Spinnaker aware Amazon VPC](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/spinnaker-aware-aws-vpc)
- [Spinnaker managed AWS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/spinnaker-managed-aws)
- [Spinnaker managed ECS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/spinnaker-managed-ecs)
- [Spinnaker managed EKS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/spinnaker-managed-eks)

## Getting started
### AWS CLI
Follow the official guide to install and configure profiles.
- [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

### Terraform
Terraform is an open-source infrastructure as code software tool that enables you to safely and predictably create, change, and improve infrastructure.

#### Install
This is the official guide for terraform binary installation. Please visit this [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) website and follow the instructions.

Or, you can manually get a specific version of terraform binary from the websiate. Move to the [Downloads](https://www.terraform.io/downloads.html) page and look for the appropriate package for your system. Download the selected zip archive package. Unzip and install terraform by navigating to a directory included in your system's `PATH`.

Or, you can use [tfenv](https://github.com/tfutils/tfenv) utility. It is very useful and easy solution to install and switch the multiple versions of terraform-cli.

First, install tfenv using brew.
```
brew install tfenv
```
Then, you can use tfenv in your workspace like below.
```
tfenv install <version>
tfenv use <version>
```
Also this tool is helpful to upgrade terraform v0.12. It is a major release focused on configuration language improvements and thus includes some changes that you'll need to consider when upgrading. But the version 0.11 and 0.12 are very different. So if some codes are written in older version and others are in 0.12 it would be great for us to have nice tool to support quick switching of version.
```
tfenv list
tfenv install latest
tfenv use <version>
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

# Known Issues
## Requires default VPC
You will see error message followings when attempting to run terraform apply in the spinnaker example if you deleted the default vpc on your account:
```
╷
│ Error: no matching VPC found
│
│ with module.spinnaker.module.eks.data.aws_vpc.default,
│ on .terraform/modules/spinnaker.eks/network.tf line 4, in data "aws_vpc" "default":
│ 4: data "aws_vpc" "default"
```
This module uses eks module inside that requires default vpc on your aws account. This is the related [issue](https://github.com/Young-ook/terraform-aws-eks/issues/44). For more details, please refer to the [source](https://github.com/Young-ook/terraform-aws-eks/).
