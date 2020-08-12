# Spinnaker managed IAM role
[Spinnaker](https://spinnaker.io/) is an open-source, multi-cloud continuous delivery platform for releasing software changes with high velocity and confidence. This is a terraform module for an IAM role to control your AWS account by Spinnaker.

## Assumptions
* You have an AWS account you want to manage by Spinnaker. This module will create an IAM role on your AWS account and the role name will be similar to the following, `<name>-<stack>-<detail>-spinnaker-managed`.

## Examples
- [Quickstart Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/modules/spinnaker-managed-aws/README.md#Quickstart)
- [Complete Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/examples/complete)

## Quickstart
### Setup
```hcl
module "spinnaker-role" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-aws"
  version = "~> 2.0"

  name             = "app"
  stack            = "prod"
  detail           = "additional-desc"
  trusted_role_arn = ["arn:aws:iam::1234567890321:role/spinnaker-test-xgsj"]
}
```
Run terraform:
```
terraform init
terraform apply
```

## Update IAM Trusted Relationship
After applying this module, you will get an ARN of IAM role from output variable. For more information about role chaining to integrate `spinnaker managed roles` with `spinnaker role`, please visit the [Quickstart Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/README.md#Quickstart).
