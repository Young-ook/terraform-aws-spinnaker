# Spinnaker
[Spinnaker](https://spinnaker.io/) is an open-source, multi-cloud continuous delivery platform for releasing software changes with high velocity and confidence. This is the terraform module to build and install spinnaker on AWS. This module will create Amazon EKS, Amazon Aurora, Amazon S3 resources for spinnaker and utilise Helm chart to install spinnaker application on kubernetes. And it will also create a VPC to place an EKS and an Aurora cluster for the spinnaker. If you want to know how to use this module, please check below examples for more details.

## Examples
- [Spinnaker Blueprint](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/blueprint)
- [AWS Modernization with Spinnaker](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/aws-modernization-with-spinnaker)

## Getting started
### AWS CLI
Follow the official guide to install and configure profiles.
- [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

After the installation is complete, you can check the aws cli version:
```
aws --version
aws-cli/2.5.8 Python/3.9.11 Darwin/21.4.0 exe/x86_64 prompt/off
```

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

### Kubernetes CLI
Here is a simple way to install the kubernetes command line tool on your environment if you are on macOS.
```
brew install kubernetes-cli
```

For more information about kubernetes tools, please visit this [page](https://kubernetes.io/docs/tasks/tools/) and follow the **kubectl** instructions if you want to install tools.

### Setup
```hcl
module "spinnaker" {
  source  = "Young-ook/spinnaker/aws"
  version = "3.0.0"
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

# Additional Resources
## Case Study
- [Netflix](https://cd.foundation/case-studies/spinnaker-case-studies/spinnaker-case-study-netflix/)
- [How Netflix Built Spinnaker, a High Velocity Continuous Delivery Platform](https://thenewstack.io/netflix-built-spinnaker-high-velocity-continuous-delivery-platform/)
- [Simplifying delivery as code with Spinnaker and Kubernetes](https://aws.amazon.com/solutions/case-studies/netflix-kubernetes-reinvent2020-video/)
- [Google Waze SRE](https://sre.google/workbook/organizational-change/)
- [AWS re:Invent 2022 - Reimagining multi-account deployments for security and speed (NFX305)](https://youtu.be/MKc9r6xOTpk)

## Netflix Projects
- [Netflix OSS](https://netflix.github.io/)
