### network
variable "region" {
  description = "The aws region to deploy the service into"
  type        = string
  default     = "us-east-1"
}

variable "azs" {
  description = "A list of availability zones for the vpc"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cidr" {
  description = "The vpc CIDR (e.g. 10.0.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

### kubernetes cluster
variable "kubernetes_version" {
  description = "The target version of kubernetes"
  type        = string
  default     = "1.14"
}

variable "kubernetes_node_groups" {
  description = "Node group definitions"
  type        = map
  default = {
    "default" = {
      "disk_size"     = "20"
      "instance_type" = "m5.xlarge"
      "max_size"      = "3"
      "min_size"      = "1"
      "desired_size"  = "1"
    }
  }
}

### rdb cluster (aurora-mysql)
variable "mysql_version" {
  description = "The target version of mysql cluster"
  type        = string
  default     = "5.7.12"
}

variable "mysql_port" {
  description = "The port number of mysql"
  type        = number
  default     = "3306"
}

variable "mysql_node_type" {
  description = "The instance type for mysql cluster"
  type        = string
  default     = "db.r4.large"
}

variable "mysql_node_size" {
  description = "The instance count of mysql (aurora) cluster"
  type        = number
  default     = "1"
}

variable "mysql_master_user" {
  description = "The name of master user of mysql"
  type        = string
  default     = "yourid"
}

variable "mysql_db" {
  description = "The name of initial database in mysql"
  type        = string
  default     = "yourdb"
}

#  [CAUTION] Changing the snapshot will force a new resource.

variable "mysql_snapshot" {
  description = "The name of snapshot to be source of new mysql cluster"
  type        = string
  default     = ""
}

variable "mysql_apply_immediately" {
  description = "specifies whether any database modifications are applied immediately, or during the next maintenance window"
  type        = bool
  default     = false
}

### security
variable "assume_role_arn" {
  description = "The list of ARNs of target AWS role that you want to manage with spinnaker. e.g.,) arn:aws:iam::12345678987:role/spinnakerManaged"
  type        = list(string)
  default     = []
}

### dns
variable "dns_zone" {
  description = "The hosted zone name for internal dns, e.g., app.internal"
  type        = string
  default     = "spinnaker.internal"
}

### helm
variable "helm_repo" {
  description = "A repositiry url of helm chart to deploy a spinnaker"
  type        = string
  default     = "https://kubernetes-charts.storage.googleapis.com"
}

variable "helm_timeout" {
  description = "Timeout value to wailt for helm chat deployment"
  type        = number
  default     = 600
}

variable "helm_chart_version" {
  description = "The version of helm chart to deploy spinnaker"
  type        = string
  default     = "2.1.0-rc.1"
}

variable "helm_chart_values" {
  description = "A list of variables of helm chart to configure the spinnaker deployment"
  type        = list
  default     = []
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = "spin"
}

variable "stack" {
  description = "Text used to identify stack of infrastructure components"
  type        = string
  default     = "default"
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
