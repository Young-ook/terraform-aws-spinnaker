# Full example of spinnaker module for AWS

## Usage example
You can use this module like below. This shows how to create the resources for spinnaker. This module will create vpc, subnets, s3 bucket, iam policies and kubernetes cluster.

### Setup
This is the first step to create a spinnaker cluster. Just get terraform module and apply it with your custom variables.
```hcl
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 1.21.0"
}

provider "aws" {
  alias               = "preprod"
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id_preprod]
  version             = ">= 1.21.0"
}

provider "aws" {
  alias               = "prod"
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id_prod]
  version             = ">= 1.21.0"
}

# spinnaker
module "spinnaker" {
  source  = "Young-ook/spinnaker/aws"
  version = "~> 2.0"

  name                    = var.name
  stack                   = var.stack
  detail                  = var.detail
  tags                    = var.tags
  region                  = var.aws_region
  azs                     = var.azs
  cidr                    = var.cidr
  kubernetes_version      = var.kubernetes_version
  kubernetes_node_groups  = var.kubernetes_node_groups
  aurora_cluster          = var.aurora_cluster
  dns_zone                = var.dns_zone
  helm_chart_version      = "2.1.0-rc.1"
  helm_chart_values       = [file(var.helm_chart_values_file)]
  assume_role_arn         = [
    module.spinnaker-managed-role-preprod.role_arn,
    module.spinnaker-managed-role-prod.role_arn,
  ]
}

# spinnaker managed role (preprod)
module "spinnaker-managed-preprod" {
  source  = "Young-ook/spinnaker-managed/aws"
  version = "~> 1.0"

  providers        = { aws = aws.preprod }
  name             = "spinnaker"
  detail           = "preprod"
  trusted_role_arn = [module.spinnaker.role_arn]
}

# spinnaker managed role (prod)
module "spinnaker-managed-prod" {
  source  = "Young-ook/spinnaker-managed/aws"
  version = "~> 1.0"

  providers        = { aws = aws.prod }
  name             = "spinnaker"
  detail           = "prod"
  trusted_role_arn = [module.spinnaker.role_arn]
}
```
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
After then you will see so many resources like EKS, S3, IAM, RDS, and others on AWS. For more information about role chaining to integrate `spinnaker managed roles` with `spinnaker role`, please visit the [Quickstart Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/README.md#Quickstart).
