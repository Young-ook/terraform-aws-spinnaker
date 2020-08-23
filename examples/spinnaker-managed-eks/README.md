# Full example of spinnaker-managed-eks module

## Usage example
### Setup
This is the first step to create a spinnaker managed EKS on your AWS account. Just get terraform module and apply it with your custom variables.
```hcl
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
}

# spinnaker managed eks
module "spinnaker-managed-eks" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-eks"
  version = "~> 2.0"

  name               = "example"
  stack              = "dev"
  detail             = "module-test"
  tags               = { env = "dev" }
  subnets            = ["subnet-1234567", "subnet-7654321", "subnet-1357353"]
  kubernetes_version = "1.17"
  node_groups = {
    default = {
      min_size      = 1
      max_size      = 3
      desired_size  = 2
      instance_type = "t3.large"
      instances_distribution = {
        on_demand_allocation_strategy            = null
        on_demand_base_capacity                  = null
        on_demand_percentage_above_base_capacity = null
        spot_allocation_strategy                 = "capacity-optimized"
        spot_instance_pools                      = null
        spot_max_price                           = "0.03"
      }
      launch_override = [
        {
          instance_type     = "t3.small"
          weighted_capacity = 3
        },
        {
          instance_type     = "t3.medium"
          weighted_capacity = 2
        }
      ]
    }
  }
}

module "irsa" {
  source  = "Young-ook/spinnaker/aws//modules/spinnaker-managed-eks//modules/iam-role-for-serviceaccount"
  version = "~> 2.0"

  namespace      = "default"
  serviceaccount = "irsa-test"
  oidc_url       = module.spinnaker-managed-eks.oidc_url
  oidc_arn       = module.spinnaker-managed-eks.oidc_arn
  policy_arns    = ["arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
  tags           = { env = "dev" }
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

After then you will see the created EKS cluster and node groups and IAM role. For more information about configuration of service account mapping for IAM role in Kubernetes, please check out the [Quickstart Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/modules/spinnaker-managed-eks/README.md#Quickstart)
