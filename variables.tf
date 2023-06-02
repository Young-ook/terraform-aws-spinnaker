### features
variable "features" {
  description = "Feature toggles for spinnaker configuration"
  type        = any
  default = {
    aurora = {
      enabled = false
    }
    eks = {
      version     = "1.24"
      ssm_enabled = false
    }
    s3 = {
      enabled       = false
      force_destroy = false
      versioning    = false
    }
  }
}

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
  default     = null
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
