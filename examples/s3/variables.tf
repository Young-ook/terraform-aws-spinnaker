# Variables for providing to module fixture codes

### network
variable "aws_region" {
  description = "The aws region to deploy"
  type        = string
}

### s3
variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "A configuration to enable object version control"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "A configuration of object lifecycle management"
  default     = []
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = "s3"
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
