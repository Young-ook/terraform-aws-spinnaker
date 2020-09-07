# Example of Spinnaker Managed ECS

## Setup
[This](main.tf) is the example of terraform configuration file to create a spinnaker managed ECS on your AWS account. Check out and apply it using terraform command.

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

After then you will see the created ECS cluster. And you can see the EC2 autoscaling group(s) if you selected the EC2 for node groups.
