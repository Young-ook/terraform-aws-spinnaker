# AWS Application Modernization with Spinnaker

![aws-modernization-with-spinnaker](../../images/aws-modernization-with-spinnaker.png)

## Setup
This is an aws modern application with hashicorp and spinnaker. The [main.tf](main.tf) is the terraform configuration file to create network infrastructure and kubernetes cluster, and spinnaker on your AWS account.

Run terraform:
```
terraform init
terraform apply -target module.foundation
```

To set up DevOps platform to another VPC, run below command:
```
terraform apply -target module.platform
```

## Clean up
Run command:
```
./uninstall.sh
terraform destroy
```
