# Amazon Simple Storage Service (S3)

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-spinnaker
cd terraform-aws-spinnaker/examples/s3
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-spinnaker/blob/main/examples/s3/main.tf) is an example of terraform configuration file to create an Amazon S3 bucket. Check out and apply it using terraform command.

If you don't have the terraform and kubernetes tools in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-spinnaker) of this repository and follow the installation instructions.

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

## Clean up
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file tc1.tfvars
```
