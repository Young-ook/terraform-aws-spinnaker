## requirements

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws    = ">= 1.20.0"
    random = ">= 2.2.0"
    helm   = ">=1.2.0"
  }
}
