# Variables for providing to module fixture codes

### network
variable "aws_region" {
  description = "The aws region to deploy"
  type        = string
  default     = "ap-northeast-2"
}

variable "azs" {
  description = "A list of availability zones for the vpc to deploy resources"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

variable "cidr" {
  description = "The list of CIDR blocks to allow ingress traffic for db access"
  type        = string
  default     = "10.0.0.0/16"
}

### kubernetes cluster
variable "kubernetes_version" {
  description = "The target version of kubernetes"
  type        = string
  default     = "1.28"
}

variable "kubernetes_node_groups" {
  description = "EKS managed node groups definition"
  default     = null
}

### rdb cluster
variable "aurora_cluster" {
  description = "RDS Aurora for mysql cluster definition"
  default     = {}
}

variable "aurora_instances" {
  description = "RDS Aurora for mysql instances definition"
  default     = []
}

### s3 bucket
variable "s3_bucket" {
  description = "S3 bucket configuration"
  default     = {}
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = "spinnaker"
}

variable "stack" {
  description = "Text used to identify stack of infrastructure components"
  type        = string
  default     = ""
}

variable "detail" {
  description = "The extra description of module instance"
  type        = string
  default     = ""
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
