# Frigga naming rule
[Netflix Frigga](https://github.com/Netflix/frigga) is a standalone Java library containing the logic Netflix's Asgard project uses for generating and parsing AWS object names. This is a terraform module to generate a resource name following Frigga naming rule to avoid resource name duplication, and it makes your resources are aware of Spinnaker.

From Norse mythology. the name Frigga refers the wife of Odin, queen of Asgard.

## Assumptions
* You have an AWS account you want to manage by Spinnaker. This module will create a name similar to the following, `<name>-<stack>-<detail>-<random-id>`.

## Quickstart
### Setup
```hcl
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = ">= 2.0"
  name    = "app"
  stack   = "prod"
  detail  = "additional-desc"
}
```
Run terraform:
```
terraform init
terraform apply
```

And you will see the outputs.
```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

name = app-prod-additional-desc-bjmqc
nametag = {
  "Name" = "app-prod-additional-desc-bjmqc"
}
```

If you don't want to append a random identifier to the end of generated frigga name, please set petname variable to `false` when applyng the module.
```hcl
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = ">= 2.0"
  name    = "app"
  stack   = "prod"
  detail  = "additional-desc"
  petname = false
}
```
