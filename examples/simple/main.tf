# Simple example

module "spinnaker" {
  source       = "git::git@github.com:Young-ook/terraform-aws-spinnaker.git?ref=1.0.0"
  name         = "spinnaker"
  stack        = "preprod"
  tags         = { "env" = "preprod" }
  region       = "us-east-1"
  azs          = ["us-east-1a", "us-east-1b", "us-east-1c"]
  dns_zone     = "app.internal"
  ssl_cert_arn = "arn:aws:acm:us-east-1:1234567890321:certificate/4a6b2a09-246a-4e7b-9850-a4251e123"
}
