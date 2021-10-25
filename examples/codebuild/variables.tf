# Variables for providing to module fixture codes

### network
variable "aws_region" {
  description = "The aws region to deploy"
  type        = string
}

### codebuild
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
