# Amazon Aurora
[Amazon Aurora](https://aws.amazon.com/rds/aurora/) is a MySQL and PostgreSQL-compatible relational database built for the cloud, that combines the performance and availability of traditional enterprise databases with the simplicity and cost-effectiveness of open source databases.

## Assumptions
* You want to create an Amazon Aurora cluster for MySQL database for spinnaker microservices. This module will create an RDS for Aurora cluster and database instances.

## Examples
- [Quickstart Example](README.md#Quickstart)
- [Complete Example](https://github.com/Young-ook/terraform-aws-spinnaker/tree/master/examples/spinnaker/README.md)

## Quickstart
### Setup
```hcl
module "rds" {
  source  = "Young-ook/spinnaker/aws//modules/aurora"
  version = "~> 2.0"

  name             = "example"
  vpc              = "vpc-123456"
  subnets          = ["subnet-12345678", "subnet-23453243", "subnet-72192989"]
  cidrs            = ["10.0.0.0/16"]
  tags             = { "env" = "test" }
  aurora_cluster = {
    version = "5.7.12"
    port    = "3306"
  }
  aurora_instances = {
    default = {
      node_type = "db.t3.medium"
    }
  }
}
```
Run terraform:
```
terraform init
terraform apply
```
