# Spinnaker
[Spinnaker](https://spinnaker.io/) is an open-source, multi-cloud continuous delivery platform for releasing software changes with high velocity and confidence. This is the terraform module to build and manage spinnaker on AWS. If you want to know how to use this module please check below examples.

## Assumptions
* You want to create a Spinnaker on AWS. This module will create a Spinnaker running on EKS (Elastic Kubernetes Service) cluster.
* You don't have a VPC (Virtual Private Cloud) where you intend to pu the EKS cluster for Spinnaker deployment. This module will create a VPC and subnets satisfies EKS requirements.

## Examples
- [Quickstart Example](README.md#Quickstart)
- [Complete Example](examples/spinnaker)

## Quickstart
### Setup
```hcl
module "spinnaker" {
  source  = "Young-ook/spinnaker/aws"
  version = "~> 2.0"

  name    = "spinnaker"
  stack   = "test"
  tags    = { "env" = "test" }
}
```
Run terraform:
```
terraform init
terraform apply
```

### Generate kubernetes config
This terraform module will give you a shell script to get kubeconfig file of an EKS cluster. You will find the [update-kubeconfig.sh](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/script/update-kubeconfig.sh) script in the `script` directory of this repository. You can get the kubeconfig file with credentials to access your EKS cluster using this script. For more detail of how to use this, please refer to the help message of the script.

[Important] Before you run this script you must configure your local environment to have proper permission to get the credentials from EKS cluster on your AWS account whatever you are using aws-cli or aws-vault.

### Access the spinnaker
```
export KUBECONFIG=<path-to-spinnaker-kubeconfig-file>
kubectl -n spinnaker port-forward svc/spin-deck 9000:9000
```
![Spinnaker](/images/cluster-management.png)

## Update the trusted relationship
### Create a spinnaker managed role
After you've done previous step to lanuch a spinnaker, you can now start to integrate with an AWS account as `spinnaker managed` to make it to be managed by your spinnaker. Here is the [terrform module](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/modules/spinnaker-managed-aws). It will help you to convert your AWS account to be controlled by the spinnaker. Back to the terraform configuration file after applying the `spinnaker-managed` module on your target AWS account, and add the ARN you've generated by the `spinnaker-managed` into the `assume_role_arn` variable of spinnaker. For more details, please refer to the **Update the spinnaker role** below.
```hcl
module "spinnaker-managed" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-aws"
  version = "~> 2.0"

  name             = "app"
  stack            = "prod"
  detail           = "additional-desc"
  trusted_role_arn = ["arn:aws:iam::1234567890321:role/spinnaker-test-xgsj"]
}
```

### Update the spinnaker role
After applying `spinnaker-managed-aws` submodule, you will get an ARN of IAM role from output variable. It may look like `arn:aws:iam::012345678912:role/spinnaker-managed-preprod`. Don't forget you have to add the spinnaker managed role to `assume_role_arn` list of spinnaker terraform module, because spinnaker application needs a permission to access the target AWS accounts via assume role API using AWS SDK. Here is an example to show how to link the spinnaker managed roles to spinnaker role.
```hcl
module "spinnaker" {
  source  = "Young-ook/spinnaker/aws"
  version = "~> 2.0"

  ...
  assume_role_arn = [module.spinnaker-managed.role_arn]
}
```
