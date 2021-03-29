# AWS Partition
A Partition is a group of AWS Region and Service objects. You can use a partition to determine what services are available in a region, or what regions a service is available in.
This module provides the attributes of current IAM identity of API caller, the current AWS Partition and Region information where you are running terraform.

## Quickstart
### Setup
```hcl
module "aws-partitions" {
  source  = "Young-ook/spinnaker/aws//modules/aws-partitions"
  version = ">= 2.0"
}
```
Run terraform:
```
terraform init
terraform apply
```

And you will see the outputs.
```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

caller = {
  "account_id" = "111122223333"
  "arn" = "arn:aws:sts::111122223333:assumed-role/admin/your-iam-user"
  "id" = "111122223333"
  "user_id" = "AXXXXXXXXXXXXXXXXAAAAXXXXYYYY:your-iam-user"
}
partition = {
  "dns_suffix" = "amazonaws.com"
  "id" = "aws"
  "partition" = "aws"
  "reverse_dns_prefix" = "com.amazonaws"
}
region = {
  "description" = "US East (N. Virginia)"
  "endpoint" = "ec2.us-east-1.amazonaws.com"
  "id" = "us-east-1"
  "name" = "us-east-1"
}
```
