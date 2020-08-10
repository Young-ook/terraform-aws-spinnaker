### description
variable "name" {
  description = "The logical name of the application/service instance"
  type        = string
}

variable "stack" {
  description = "Text used to identify stack of infrastructure components (e.g., dev, prod)"
  type        = string
  default     = "default"
}

variable "detail" {
  description = "The purpose or extra description of your application/service instance"
  type        = string
  default     = ""
}

variable "petname" {
  description = "An indicator whether to append a random identifier to the end of the name to avoid duplication"
  type        = bool
  default     = true
}
