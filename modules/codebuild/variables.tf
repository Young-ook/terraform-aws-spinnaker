### network
variable "vpc" {
  description = "VPC configuration"
  type        = map(any)
  default     = null
}

### build project
variable "project" {
  description = "Build project configuration"
  type        = any
  default = {
    source = {}
    environment = {
      environment_vars = []
    }
    artifact = {}
  }
}

### log
variable "log" {
  description = "Log configuration"
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
