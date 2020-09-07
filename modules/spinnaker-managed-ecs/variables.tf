### network
variable "subnets" {
  description = "The list of subnet IDs to deploy your EKS cluster"
  type        = list(string)
  default     = null
}

### ecs cluster
variable "node_groups" {
  description = "Node groups definition"
  type        = map
  default     = null
}

### feature
variable "container_insights_enabled" {
  description = "A boolean variable indicating to enable ContainerInsights"
  type        = bool
  default     = false
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = "ecs"
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
