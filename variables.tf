### network
variable "vpc" {
  description = "A VPC Id. for spinnaker"
  type        = string
}

variable "subnets" {
  description = "A list of subnet IDs for spinnaker"
  type        = list(string)
}

variable "cidrs" {
  description = "The CIDR block to allow database traffic (e.g. 10.0.0.0/16)"
  type        = list(string)
}

### helm
variable "helm" {
  description = "The helm chart configuration"
  default     = {}
}

### kubernetes cluster
variable "kubernetes_version" {
  description = "The target version of kubernetes"
  type        = string
  default     = "1.21"
}

variable "kubernetes_node_groups" {
  description = "Node groups definition"
  default     = null
}

variable "kubernetes_enable_ssm" {
  description = "Allow ssh access using session manager"
  type        = bool
  default     = false
}

variable "kubernetes_policy_arns" {
  description = "A list of policy ARNs to attach the node groups role"
  type        = list(string)
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "A list of the desired control plane logging to enable"
  type        = list(string)
  default     = []
}

### rdb cluster (aurora-mysql)
variable "aurora_cluster" {
  description = "RDS Aurora for mysql cluster definition"
  default     = null
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

### security
variable "assume_role_arn" {
  description = "The list of ARNs of target AWS role that you want to manage with spinnaker. e.g.,) arn:aws:iam::12345678987:role/spinnakerManaged"
  type        = list(string)
  default     = []
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
