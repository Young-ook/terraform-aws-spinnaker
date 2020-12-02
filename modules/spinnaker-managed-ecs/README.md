# Amazon ECS (Elastic Container Service)
[Amazon ECS](https://aws.amazon.com/ecs/) is a fully managed container orchestration service. Customers such as Duolingo, Samsung, GE, and Cookpad use ECS to run their most sensitive and mission critical applications because of its security, reliability, and scalability.

* You want to create a spinnaker managed ECS on AWS. This module will create an ECS cluster and capacity providers.

## Quickstart
### Setup
```hcl
module "ecs" {
  source   = "Young-ook/spinnaker/aws//modules/spinnaker-managed-ecs"
  version  = ">= 2.0"
  name     = "example"
}
```
Run terraform:
```
terraform init
terraform apply
```
