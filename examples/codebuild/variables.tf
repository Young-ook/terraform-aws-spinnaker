# Variables for providing to module fixture codes

### network
variable "aws_region" {
  description = "The aws region to deploy"
  type        = string
}

variable "azs" {
  description = "A list of availability zones for the vpc to deploy resources"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "use_default_vpc" {
  description = "A feature flag for whether to use default vpc"
  type        = bool
  default     = true
}

### codebuild
variable "artifact_config" {
  description = "artifact configuration"
  default     = {}
}

variable "environment_config" {
  description = "Environment configuration"
  default     = {}
}

variable "source_config" {
  description = "Source repository configuration"
  default     = {}
}

variable "log_config" {
  description = "Log configuration"
  type        = map(any)
  default     = null
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = "codebuild"
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
