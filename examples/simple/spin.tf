# Complete example 

module "spinnaker" {
  source  = "tf-mod/spinnaker/aws"
  version = "1.0.0"

  name         = "spinnaker"
  stack        = "preprod"
  region       = "{var.aws_region}"
  azs          = ["{var.aws_azs}"]
  aws_profile  = "{var.aws_profile}"
  ssl_cert_arn = "{var.ssl_cert_arn}"
  dns_zone     = "app.internal"
  tags = {
    "name" = "test"
  }
}
