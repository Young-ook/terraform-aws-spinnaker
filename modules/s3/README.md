# Amazon S3 (Simple Storage Service)
[Amazon S3](https://aws.amazon.com/s3/) is an object storage service that offers industry-leading scalability, data availability, security, and performance.

## Quickstart
### Setup
```hcl
module "s3" {
  source  = "Young-ook/spinnaker/aws//modules/s3"
  name    = var.name
  tags    = { env = "test" }
}
```
Run terraform:
```
terraform init
terraform apply
```

## Object Lifecycle Management
To manage your objects so that they are stored cost effectively throughout their lifecycle, configure their Amazon S3 Lifecycle. An S3 Lifecycle configuration is a set of rules that define actions that Amazon S3 applies to a group of objects. There are two types of actions:
*  **Transition actions** Define when objects transition to another storage class. For example, you might choose to transition objects to the S3 Standard-IA storage class 30 days after you created them, or archive objects to the S3 Glacier storage class one year after creating them. There are costs associated with the lifecycle transition requests. For pricing information, see Amazon S3 pricing
* **Expiration actions** Define when objects expire. Amazon S3 deletes expired objects on your behalf. The lifecycle expiration costs depend on when you choose to expire objects.

For more information, see [Object lifecycle management](https://docs.aws.amazon.com/AmazonS3/latest/dev/object-lifecycle-mgmt.html).
### Example
```hcl
module "s3" {
  source  = "Young-ook/spinnaker/aws//modules/s3"
  name    = var.name
  tags    = { env = "test" }

  lifecycle_rules = [{
    enabled = "true"
    transition = [{
      days          = "120"
      storage_class = "STANDARD_IA"
    }]
    expiration = {
      days = "160"
    }
  }]
}
```
Modify the terraform configuration file to add a lifecycle rule to apply objects in the S3 bucket.
```
terraform init
terraform apply
```
