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

  name               = "example"
  stack              = "dev"
  detail             = "module-test"
  tags               = { "env" = "dev" }
  region             = "us-east-1"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cidr               = "10.0.0.0/16"
  dns_zone           = "your.private"

  kubernetes_version = "1.16"
  kubernetes_node_groups = {
    default = {
      instance_type = "m5.large"
      min_size      = "1"
      max_size      = "3"
      desired_size  = "2"
    }
  }

  aurora_cluster = {
    node_size = "1"
    node_type = "db.t3.medium"
    version   = "5.7.12"
  }

  helm = {
    name            = "cd"
    repository      = "https://kubernetes-charts.storage.googleapis.com"
    chart           = "spinnaker"
    version         = "2.2.2"
    namespace       = "spinnaker"
    timeout         = "500"
    cleanup_on_fail = "true"
    values          = join("/", [path.cwd, "values.yaml"])
  }

  assume_role_arn = [
    module.spinnaker-managed-role-preprod.role_arn,
    module.spinnaker-managed-role-prod.role_arn,
  ]
}

# spinnaker managed role (preprod)
module "spinnaker-managed-role-preprod" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-aws"
  version = "~> 2.0"

  providers        = { aws = aws.preprod }
  name             = "spinnaker"
  stack            = "preprod"
  detail           = "additional-desc"
  trusted_role_arn = [module.spinnaker.role_arn]
}

# spinnaker managed role (prod)
module "spinnaker-managed-role-prod" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-aws"
  version = "~> 2.0"

  providers        = { aws = aws.prod }
  name             = "spinnaker"
  stack            = "prod"
  detail           = "additional-desc"
  trusted_role_arn = [module.spinnaker.role_arn]
}

# spinnaker managed role (gcp)
module "spinnaker-managed-role-gcp" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-gcp"
  version = "~> 2.0"

  desc    = "dev"
  project = "yourproj"
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
