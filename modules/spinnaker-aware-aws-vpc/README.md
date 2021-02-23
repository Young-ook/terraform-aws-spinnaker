# Amazon VPC
[Amazon Virtual Private Cloud(Amazon VPC)](https://aws.amazon.com/vpc/) is a service that lets you launch AWS resources in a logically isolated virtual network that you define. You have complete control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways. You can use both IPv4 and IPv6 for most resources in your virtual private cloud, helping to ensure secure and easy access to resources and applications.

## Quickstart
### Setup
```hcl
module "vpc" {
  source           = "Young-ook/spinnaker/aws//modules/spinnaker-aware-aws-vpc"
  version          = ">= 2.0"
  name             = "example"
}
```
Run terraform:
```
terraform init
terraform apply
```
