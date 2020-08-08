# Spinnaker managed Cloud IAM role
[Spinnaker](https://spinnaker.io/) is an open-source, multi-cloud continuous delivery platform for releasing software changes with high velocity and confidence. This is the terraform module to make a service account of GCP project to be managed by spinnaker.

## Examples
- [Quickstart Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/modules/spinnaker-managed-gcp/README.md#Quickstart)
- [Complete Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/examples/complete)

## Quickstart
### Setup
```hcl
module "spinnaker-managed-role" {
  source  = "Young-ook/spinnaker/aws/modules/spinnaker-managed-gcp"
  version = "~> 2.0"

  desc    = "dev"
  project = "yourproj"
}
```
Run terraform:
```
terraform init
terraform apply
```
