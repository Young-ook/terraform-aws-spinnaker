# Spinnaker
[Spinnaker](https://spinnaker.io/) is an open-source, multi-cloud continuous delivery platform for releasing software changes with high velocity and confidence. This is the terraform module to build and manage spinnaker on AWS. If you want to know how to use this module please check below examples.

## Assumptions
* You want to create a Spinnaker on AWS. This module will create a Spinnaker running on EKS (Elastic Kubernetes Service) cluster.
* You don't have a VPC (Virtual Private Cloud) where you intend to pu the EKS cluster for Spinnaker deployment. This module will create a VPC and subnets to meet the EKS requirements.
* This module will create an Amazon Aurora cluster, S3 bucket and accociated permission policy for spinnaker storage.

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

## Enable AWS account in spinnaker
To enable AWS account in the spinnaker, you have to access the halyard pod using `kubectl` command.
```
kubectl -n spinnaker exec -it cd-spinnaker-halyard-0 -- bash
bash $ hal config provider aws account add aws-test \
    --account-id '0123456879031' \
    --assume-role role/spinnaker-test-xgsj \
    --regions us-east-1, us-west-2
bash $ hal config provider aws enable
bash $ hal deploy apply
```
After you configure the Spinnaker AWS provider you can manage AWS resources depending on what you included in the AWS policy. You would be able to deploy EC2 resources with Spinnaker.

## Enable AWS ECS account in spinnaker
This is an example code to enable AWS ECS account in spinnaker. In this example `ecs-test` is the name of the Amazon ECS account in spinnaker, and `aws-test` is the name of previously added, valid AWS account. Please note that the ECS account uses the same credential from correspoding AWS account. You don't need to configure an additional assumeable role for ECS account.
```
kubectl -n spinnaker exec -it cd-spinnaker-halyard-0 -- bash
bash $ hal config provider ecs account add ecs-test --aws-account aws-test
bash $ hal config provider ecs enable
bash $ hal deploy apply
```
For more information, please refer to [this](https://spinnaker.io/setup/install/providers/aws/aws-ecs/) provider configuration document.
