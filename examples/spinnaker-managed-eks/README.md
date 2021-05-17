# Spinnaker Managed EKS

## Setup
[This](main.tf) is the example of terraform configuration file to create a spinnaker managed EKS on your AWS account. Check out and apply it using terraform command.

Run terraform:
```
terraform init
terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file tc1.tfvars
terraform apply -var-file tc1.tfvars
```

## Enabling Kubernetes account
To enable a Kubernetes account in your spinnaker, please check out [this](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/spinnaker-managed-eks) for more details.

## Clean up
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file tc1.tfvars
```
