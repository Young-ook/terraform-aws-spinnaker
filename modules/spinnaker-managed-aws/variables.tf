### feature
variable "base_role_enabled" {
  description = "A boolean variable to indicate whether to create a BaseIAMRole for EC2 deployment"
  type        = bool
  default     = false
}

### security/trusted-roles
variable "trusted_role_arn" {
  description = "A list of full arn of iam roles of spinnaker cluster"
  type        = list(string)
  default     = []
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = "spin"
}

variable "stack" {
  description = "Text used to identify stack of infrastructure components"
  type        = string
  default     = "default"
}

variable "detail" {
  description = "The purpose of your aws account"
  type        = string
  default     = ""
}
