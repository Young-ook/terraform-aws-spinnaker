# Example of CodeBuild for Spinnaker Pipeline

## Setup
You can use this module like below. This shows how to create the codebuild project for spinnaker pipeline. [This](main.tf) is the example of terraform configuration file to create codebuild projects on your AWS account. Check out and apply it using terraform command.

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
