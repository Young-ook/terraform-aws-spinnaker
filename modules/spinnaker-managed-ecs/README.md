# Amazon ECS (Elastic Container Service)
[Amazon ECS](https://aws.amazon.com/ecs/) is a fully managed container orchestration service. Customers such as Duolingo, Samsung, GE, and Cookpad use ECS to run their most sensitive and mission critical applications because of its security, reliability, and scalability. This module will create an ECS cluster and capacity providers.

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

## Enabling AWS ECS account in spinnaker
This is an example code to enable AWS ECS account in the spinnaker. In this example `ecs-test` is the name of the Amazon ECS account in spinnaker, and `aws-test` is the name of previously added, valid AWS account. Please note that the ECS account uses the same credential from correspoding AWS account. You don't need to configure an additional assumeable role for ECS account.
```
kubectl -n spinnaker exec -it cd-spinnaker-halyard-0 -- bash
bash $ hal config provider ecs account add ecs-test --aws-account aws-test
bash $ hal config provider ecs enable
bash $ hal deploy apply
```
For more information, please refer to [this](https://spinnaker.io/setup/install/providers/aws/aws-ecs/).

# Additional Resources
- [Amazon ECS Workshop](https://ecsworkshop.com/)
- [Amazon ECS Scalability Best Practices](https://nathanpeck.com/amazon-ecs-scaling-best-practices/)
