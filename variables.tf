# variables.tf

### network
variable "region" {
  description = "The aws region to deploy the service into"
  default     = "us-east-1"
}

variable "azs" {
  description = "A list of availability zones for the vpc"
  type        = "list"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cidr" {
  description = "The vpc CIDR (e.g. 10.0.0.0/16)"
  default     = "10.0.0.0/16"
}

### kubernetes cluster
variable "kube_version" {
  description = "The target version of kubernetes"
  default     = "1.11"
}

variable "kube_node_type" {
  description = "The instance type for kubernetes worker nodes"
  default     = "m5.large"
}

variable "kube_node_size" {
  description = "The instance count for kubernetes worker nodes"
  default     = "3"
}

variable "kube_node_vol_size" {
  description = "The volume size of each kubernetes worker node"
  default     = "50"
}

variable "kube_node_vol_type" {
  description = "The volume type of each kubernetes worker node"
  default     = "gp2"
}

variable "kube_node_ami" {
  description = "The specific ami id what you want to be a source image of kubernetes worker nodes"
  default     = ""
}

### s3 storage
variable "s3_prefixies" {
  description = "The list of key objects to be pregenerated when bucket creating"
  default     = ["front50", "kayenta", "halyard"]
}

### docker registry
variable "ecr_repos" {
  default = []
}

### credentials
variable "aws_profile" {
  description = "A profile name for aws cli"
  default     = "default"
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = "map"
}

### security
variable "elb_sec_policy" {
  description = "Registered security policy"
  default     = "ELBSecurityPolicy-2016-08"
}

variable "ssl_cert_arn" {
  description = "Registered ssl cretification for internal services"
  default     = ""
}

variable "assume_role_arn" {
  description = "The list of arns to allow assume role from spinnaker. e.g.,) arn:aws:iam::12345678987:role/spinnakerManaged"
  default     = []
}

### description
variable "name" {
  description = "The logical name of the module instance"
  default     = "spin"
}

variable "stack" {
  description = "Text used to identify stack of infrastructure components"
  default     = "default"
}

variable "detail" {
  description = "The extra description of module instance"
  default     = ""
}

variable "slug" {
  description = "A random string to be end of tail of module name"
  default     = ""
}

### dns
variable "dns_zone" {
  description = "The hosted zone name for internal dns, e.g., ${var.dns_zone}.internal"
}
