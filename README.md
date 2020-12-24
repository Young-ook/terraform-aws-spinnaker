# Spinnaker
[Spinnaker](https://spinnaker.io/) is an open-source, multi-cloud continuous delivery platform for releasing software changes with high velocity and confidence. This is the terraform module to build and install spinnaker on AWS. This module will create Amazon EKS, Amazon Aurora, Amazon S3 resources for spinnaker and utilise Helm chart to install spinnaker application on kubernetes. And it will also create a VPC to place an EKS and an Aurora cluster for the spinnaker. If you want to know how to use this module, please check below examples for more details.

## Examples
- [Spinnaker](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/spinnaker)
- [CodeBuild](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/codebuild)
- [Spinnaker managed AWS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/spinnaker-managed-aws)
- [Spinnaker managed ECS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/spinnaker-managed-ecs)
- [Spinnaker managed EKS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/spinnaker-managed-eks)
- [Chaos Monkey](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/chaosmonkey)

## Quickstart
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
This terraform module will give you a shell script to get kubeconfig file of an EKS cluster. You will find the [update-kubeconfig.sh](https://github.com/Young-ook/terraform-aws-eks/blob/main/script/update-kubeconfig.sh) script in the `script` directory of this repository. You can get the kubeconfig file with credentials to access your EKS cluster using this script. For more detail of how to use this, please refer to the help message of the script.

**[Important]** Before you run this script you must configure your local environment to have proper permission to get the credentials from EKS cluster on your AWS account whatever you are using aws-cli or aws-vault.

### Access the spinnaker
```
export KUBECONFIG=<path-to-spinnaker-kubeconfig-file>
kubectl -n spinnaker port-forward svc/spin-deck 9000:9000
```
![Spinnaker](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/images/cluster-management.png)

## Cloud Providers
#### AWS
Users can add AWS account to spinnaker using halyard which is the command-line tool for spinnaker management. To enable AWS account in the spinnaker, please follow the instructions in the [Spinnaker Managed AWS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/spinnaker-managed-aws) example.

#### ECS
And users can enable ECS account in the spinnaker using halyard. Please follow the instructions in the [Spinnaker Managed ECS](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/spinnaker-managed-ecs) example.

## Continuous Integration
#### CodeBuild
Users can set up AWS CodeBuild as a Continuous Integration (CI) system within spinnaker for cloud backed build system. For more details about codebuild project registration with spinnaker, please visit the [Enable AWS CodeBuild account](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/codebuild).
