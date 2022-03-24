### network
variable "azs" {
  description = "A list of availability zones for the vpc"
  type        = list(any)
}

variable "cidr" {
  description = "The vpc CIDR (e.g. 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

### kubernetes
variable "kubernetes_version" {
  description = "The target version of kubernetes"
  type        = string
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
