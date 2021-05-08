### network
variable "cidr" {
  description = "The vpc CIDR (e.g. 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones for the vpc"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_endpoint_config" {
  description = "A list of vpc endpoint configurations"
  type        = list
  default     = null
}

### feature
variable "enable_igw" {
  description = "Should be true if you want to provision Internet Gateway for internet facing communication"
  type        = bool
  default     = true
}

variable "enable_ngw" {
  description = "Should be true if you want to provision NAT Gateway(s) across all of private networks"
  type        = bool
  default     = false
}

variable "single_ngw" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of private networks"
  type        = bool
  default     = false
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = "vpc"
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
