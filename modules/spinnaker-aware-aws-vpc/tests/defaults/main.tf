terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "main" {
  source = "../../"
  cidr   = "10.0.0.0/16"
  name   = "service"
  stack  = "stack"
  detail = "vpc"
  tags   = { test = "spinnaker-aware-vpc-default" }
}

output "vpc" {
  description = "Atributes of spinnaker aware vpc"
  value       = module.main.vpc
}
