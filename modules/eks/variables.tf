### network
variable "subnets" {
  description = "The list of subnet IDs to deploy your EKS cluster"
  type        = list(string)
  default     = null
}

### kubernetes cluster
variable "kubernetes_version" {
  description = "The target version of kubernetes"
  type        = string
  default     = "1.17"
}

variable "node_groups" {
  description = "Node groups definition"
  type        = map
  default = {
    default = {
      min_size      = 1
      max_size      = 3
      desired_size  = 1
      instance_type = "t3.medium"
      instances_distribution = {
        on_demand_allocation_strategy            = "prioritized"
        on_demand_base_capacity                  = 0
        on_demand_percentage_above_base_capacity = 100
        spot_allocation_strategy                 = "lowest-price"
        spot_instance_pools                      = 2
        spot_max_price                           = "0.03"
      }
      launch_override = [
        {
          instance_type     = "t3.small"
          weighted_capacity = null
        }
      ]
    }
  }
}

### feature
variable "enabled_cluster_log_types" {
  description = "A list of the desired control plane logging to enable"
  type        = list(string)
  default     = []
}

variable "container_insights_enabled" {
  description = "A boolean variable indicating to enable ContainerInsights"
  type        = bool
  default     = false
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = "eks"
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
