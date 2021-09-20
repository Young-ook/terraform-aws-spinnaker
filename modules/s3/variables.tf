### security
variable "canned_acl" {
  description = "Predefined access control rule. The default is 'private' to prevent all access"
  type        = string
  default     = "private"
}

variable "lifecycle_rules" {
  description = "A configuration of object lifecycle management"
  default = [
    {
      "enabled" : "true",
      "expiration" : {
        "days" : "365"
      },
      "id" : null,
      "prefix" : null,
      "noncurrent_version_expiration" : {
        "days" : "120"
      },
      "noncurrent_version_transition" : [],
      "tags" : {},
      "transition" : [
        {
          "days" : "180",
          "storage_class" : "STANDARD_IA"
        }
      ]
    }
  ]
}

variable "logging_rules" {
  description = "A configuration of bucket logging management"
  default     = []
}

variable "server_side_encryption" {
  description = "A configuration of server side encryption"
  default     = [{ sse_algorithm = "AES256" }]
}

variable "versioning" {
  description = "A configuration to enable object version control"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
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
