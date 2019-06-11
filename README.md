# Spinnaker

## Using module
You can use this module like as below example.

```
module "your_spin" {
  source  = "terraform-aws-spinnaker"
  version = "v1.0.0"

  app_name             = "spin"
  app_detail           = "dev"
  stack_name           = "${var.stack_name}"
  region               = "${var.aws_region}"
  vpc                  = "${module.vpc.vpc_id}"
  azs                  = "${var.azs}"
  cidr                 = "${var.cidr}"
  tags                 = "${map("env", "test")}"
  aws_profile          = "default"
  kube_version         = "1.11"
  kube_node_type       = "m5.xlarge"
  kube_node_size       = "5"
  
  ecr_repo_names = "${list(
    map("org", "your-env", "repo", "monitoring-daemon"),
    map("org", "your-env", "repo", "clouddriver"),
  )}"

  assume_role_arn = "${list(
    "arn:aws:iam::1234567890321:role/spinnaker-managed-your-env"
  )}"
}

# route53/*.example.com

resource "aws_route53_record" "spnkr-ui" {
  count   = "${var.dns_zone_id == "" ? 0: 1}"
  zone_id = "${var.dns_zone_id}"
  name    = "spinnaker-dev.${var.dns_zone}"
  type    = "CNAME"
  ttl     = 300
  records = ["${var.spin_ui_dns}"]
}

resource "aws_route53_record" "spnkr-api" {
  count   = "${var.dns_zone_id == "" ? 0: 1}"
  zone_id = "${var.dns_zone_id}"
  name    = "spinnaker-dev-api.${var.dns_zone}"
  type    = "CNAME"
  ttl     = 300
  records = ["${var.spin_api_dns}"]
}

resource "aws_route53_record" "spnkr-cli" {
  count   = "${var.dns_zone_id == "" ? 0: 1}"
  zone_id = "${var.dns_zone_id}"
  name    = "spinnaker-dev-cli.${var.dns_zone}"
  type    = "CNAME"
  ttl     = 300
  records = ["${var.spin_cli_dns}"]
}

# acm/*.example.com
# certificates

resource "aws_acm_certificate" "cert" {
  count             = "${var.public_dns_zone == "" ? 0 : 1}"
  domain_name       = "*.${var.public_dns_zone}"
  validation_method = "DNS"

  tags = "${merge(
    map("Name", "${var.public_dns_zone}"),
    map("env", "${var.stack}"),
  )}"

  lifecycle {
    create_before_destroy = true
  }
}

# cert. validation

locals {
  verify_name  = "${lookup(aws_acm_certificate.cert.domain_validation_options[0], "resource_record_name")}"
  verify_value = "${lookup(aws_acm_certificate.cert.domain_validation_options[0], "resource_record_value")}"
}

resource "aws_route53_record" "cert-validation" {
  zone_id = "${var.public_dns_zone_id}"
  name    = "${local.verify_name}"
  type    = "CNAME"
  ttl     = 300
  records = ["${local.verify_value}"]
}
```
