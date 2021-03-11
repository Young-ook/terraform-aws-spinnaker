# Spinnaker Managed ECS

## Setup
[This](main.tf) is the example of terraform configuration file to create a spinnaker managed ECS on your AWS account. Check out and apply it using terraform command. After then you will see the created ECS cluster.

Run terraform:
```
terraform init
terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file default.tfvars
terraform apply -var-file default.tfvars
```

## Enabling ECS account
To enable an ECS account in your spinnaker, please check out [this](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/modules/spinnaker-managed-ecs) for more details.

## Clean up
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file default.tfvars
```
