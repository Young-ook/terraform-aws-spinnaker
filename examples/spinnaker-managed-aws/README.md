# Example of Spinnaker Managed AWS

## Setup
This is the first step to create an IAM role that makes your AWS account to be managed by Spinnaker. [This](main.tf) is the example of terraform configuration file to create an IAM role. Check out and apply it.

Run terraform:
```
terraform init
terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file=default.tfvars
terraform apply -var-file=default.tfvars
```
After then you will see the generated IAM roles and policies. For more information about role chaining to integrate `spinnaker managed roles` with `spinnaker role`, please visit the [Update the spinnaker role](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/README.md#update-the-spinnaker-role). And also check out [Enable AWS account in spinnaker](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/README.md#enable-aws-account-in-spinnaker) for configuration update of the spinnaker to enable AWS account management.
