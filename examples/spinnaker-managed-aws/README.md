# Full example of spinnaker-managed-aws module

## Usage example
### Setup
This is the first step to create a spinnaker managed IAM role on your AWS account. Just get terraform module and apply it with your custom variables.
```hcl
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 1.21.0"
}

# spinnaker managed role
module "spinnaker-managed-role-preprod" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-aws"
  version = "~> 2.0"

  name             = "spinnaker"
  stack            = "preprod"
  detail           = "additional-desc"
  trusted_role_arn = [module.spinnaker.role_arn]
}
```
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
After then you will see the generated IAM roles and policies. For more information about role chaining to integrate `spinnaker managed roles` with `spinnaker role`, please visit the [Quickstart Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/README.md#Quickstart).
