# Amazon VPC
[Amazon Virtual Private Cloud(Amazon VPC)](https://aws.amazon.com/vpc/) is a service that lets you launch AWS resources in a logically isolated virtual network that you define. You have complete control over your virtual networking environment, including selection of your own IP address range, creation of subnets, and configuration of route tables and network gateways. You can use both IPv4 and IPv6 for most resources in your virtual private cloud, helping to ensure secure and easy access to resources and applications.

## Setup
This is an example to explain how to build an Amazon VPC. [This](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/spinnaker-aware-aws-vpc/main.tf) is the example of terraform configuration file. Check out and apply it using terraform command.

Run terraform:
```
terraform init
terraform apply -var-file tc1.tfvars
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file default.tfvars
terraform apply -var-file default.tfvars
```
## Network Architecture
This module create public subnets for internet-facing connections and private subnets for internal networking. And we can disable NAT gateway(s) to make sure the instances are located in the private subnets only communicate to other instances inside VPC and AWS services via VPC endpoints. A VPC endpoint enables private connections between your VPC and supported AWS services and VPC endpoint services powered by AWS PrivateLink. AWS PrivateLink is a technology that enables you to privately access services by using private IP addresses. Traffic between your VPC and the other service does not leave the Amazon network. A VPC endpoint does not require an internet gateway, virtual private gateway, NAT device, VPN connection, or AWS Direct Connect connection. Instances in your VPC do not require public IP addresses to communicate with resources in the service. For more details, please refer to [this](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/spinnaker-aware-aws-vpc).

## Clean up
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file default.tfvars
```
