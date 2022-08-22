### description
variable "name" {
  description = "The logical name of the application/service instance"
  type        = string
  default     = null
  validation {
    condition     = var.name == null ? true : var.name != null && length(var.name) > 0
    error_message = "Length of name is longer than 0."
  }
}

variable "stack" {
  description = "Text used to identify stack of infrastructure components (e.g., dev, prod)"
  type        = string
  default     = ""
  validation {
    condition     = var.stack != null
    error_message = "Stak must not be null."
  }
}

variable "detail" {
  description = "The purpose or extra description of your application/service instance"
  type        = string
  default     = ""
  validation {
    condition     = var.detail != null
    error_message = "Detail must not be null."
  }
}

variable "petname" {
  description = "An indicator whether to append a random identifier to the end of the name to avoid duplication"
  type        = bool
  default     = true
}

variable "max_length" {
  description = "The maximum length of generated logical name"
  type        = number
  default     = 64
}
