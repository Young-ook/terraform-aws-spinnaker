# Variables for providing to module fixture codes

### network
variable "aws_region" {
  description = "The aws region to deploy the service into"
  type        = string
  default     = "us-east-2"
}

### ecs cluster
variable "node_groups" {
  description = "Node groups definition"
  default     = []
}

### feature
variable "container_insights_enabled" {
  description = "A boolean variable indicating to enable ContainerInsights"
  type        = bool
  default     = false
}

variable "termination_protection" {
  description = "A boolean variable indicating to enable Termination Protection of autoscaling group"
  type        = bool
  default     = true
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = "example"
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
