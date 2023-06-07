### input variables

### features
variable "features" {
  description = "Feature toggles for spinnaker configuration"
  type        = any
  default = {
    aurora = {
      enabled = false
    }
    eks = {
      version      = "1.24"
      ssm_enabled  = false
      cluster_logs = []
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
