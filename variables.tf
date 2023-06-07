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
    vpc = {
      id      = null
      cidrs   = []
      subnets = []
    }
  }
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
