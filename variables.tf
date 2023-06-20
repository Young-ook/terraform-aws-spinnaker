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
      role_arns    = []
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
