# Amazon EKS (Elastic Kubernetes Service)
[Amazon EKS](https://aws.amazon.com/eks/) is a fully managed Kubernetes service. Customers trust EKS to run their most sensitive and mission critical applications because of its security, reliability, and scalability.

## Assumptions
* You want to create a spinnaker managed EKS on AWS. This module will create an EKS control plane and data plane.
* This module will give you a utility bash script to configure RBAC on the EKS cluster.

## Examples
- [Quickstart Example](README.md#Quickstart)
- [Complete Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/examples/spinnaker-managed-eks/README.md)

## Quickstart
### Setup
```hcl
module "eks" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-eks"
  version = "~> 2.0"

  name    = var.name
  stack   = var.stack
  tags    = { "env" = "test" }
}
```
Run terraform:
```
terraform init
terraform apply
```
