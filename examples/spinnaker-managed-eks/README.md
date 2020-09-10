# Example of Spinnaker Managed EKS

## Setup
[This](main.tf) is the example of terraform configuration file to create a spinnaker managed EKS on your AWS account. Check out and apply it using terraform command.

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

After then you will see the created EKS cluster and node groups and IAM role. For more information about configuration of service account mapping for IAM role in Kubernetes, please check out the [Quickstart Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/modules/iam-role-for-serviceaccount/README.md#Quickstart)
