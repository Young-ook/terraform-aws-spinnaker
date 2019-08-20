### aws credential
variable "aws_account_id" {
  description = "The aws account id for the tf backend creation (e.g. 857026751867)"
}

variable "aws_profile" {
  description = "A profile name for aws cli"
}

### network
variable "aws_region" {
  description = "The aws region to deploy the service into"
}

variable "aws_azs" {
  description = "A list of availability zones for the vpc"
  type        = "list"
}

### certificates
variable "ssl_cert_arn" {
  description = "The arn of registered ssl certificates in acm"
}
