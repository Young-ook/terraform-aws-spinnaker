variable "artifact_config" {
  description = "Artifact configuration"
  type        = map(any)
  default = {
    type = "NO_ARTIFACTS"
  }
}

variable "environment_config" {
  description = "Build environment configuration"
  default     = {}
}

variable "source_config" {
  description = "Source repository configuration"
  type        = map(any)
  default     = {}
}

variable "log_config" {
  description = "Log configuration"
  type        = map(any)
  default     = null
}

variable "vpc" {
  description = "VPC configuration"
  type        = map(any)
  default     = null
}

### security
variable "policy_arns" {
  description = "A list of additional policy ARNs to attach the service role for CodeBuild"
  type        = list(string)
  default     = []
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
