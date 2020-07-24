# Variables for providing to module fixture codes

### aws credential
variable "aws_account_id" {
  description = "The aws account id for the tf backend creation (e.g. 857026751867)"
}

### network
variable "aws_region" {
  description = "The aws region to deploy the service into"
  default     = "us-east-1"
}

variable "azs" {
  description = "A list of availability zones for the vpc"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cidr" {
  description = "The vpc CIDR (e.g. 10.0.0.0/16)"
  default     = "10.0.0.0/16"
}

### kubernetes cluster
variable "kube_version" {
  description = "The target version of kubernetes"
  default     = "1.14"
}

variable "kube_node_type" {
  description = "The instance type for kubernetes worker nodes"
  default     = "m5.large"
}

variable "kube_node_size" {
  description = "The instance count for kubernetes worker nodes"
  default     = "3"
}

variable "kube_node_vol_size" {
  description = "The volume size of each kubernetes worker node"
  default     = "50"
}

variable "kube_node_vol_type" {
  description = "The volume type of each kubernetes worker node"
  default     = "gp2"
}

variable "kube_node_ami" {
  description = "The specific ami id what you want to be a source image of kubernetes worker nodes"
  default     = ""
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}

### rdb cluster (aurora-mysql)
variable "mysql_version" {
  description = "The target version of mysql cluster"
  default     = "5.7.12"
}

variable "mysql_port" {
  description = "The port number of mysql"
  default     = "3306"
}

variable "mysql_node_type" {
  description = "The instance type for mysql cluster"
  default     = "db.r4.large"
}

variable "mysql_node_size" {
  description = "The instance count of mysql (aurora) cluster"
  default     = "1"
}

variable "mysql_master_user" {
  description = "The name of master user of mysql"
  default     = "yourid"
}

variable "mysql_db" {
  description = "The name of initial database in mysql"
  default     = "yourdb"
}

#  [CAUTION] Changing the snapshot will force a new resource.

variable "mysql_snapshot" {
  description = "The name of snapshot to be source of new mysql cluster"
  default     = ""
}

variable "mysql_apply_immediately" {
  description = "specifies whether any database modifications are applied immediately, or during the next maintenance window"
  default     = false
}

### dns
variable "dns_zone" {
  description = "The hosted zone name for internal dns, e.g., app.internal"
}

### helm
variable "helm_repo" {
  description = "A repositiry url of helm chart to deploy a spinnaker"
  default     = "https://kubernetes-charts.storage.googleapis.com"
  type        = string
}

variable "helm_timeout" {
  description = "Timeout value to wailt for helm chat deployment"
  default     = 600
  type        = number
}

variable "helm_chart_version" {
  description = "The version of helm chart to deploy spinnaker"
  default     = "2.1.0-rc.1"
  type        = string
}

variable "helm_chart_values_file" {
  description = "Path to file for helm chart configuration"
  type        = string
}

### description
variable "name" {
  description = "The logical name of the module instance"
  default     = "spin"
}

variable "stack" {
  description = "Text used to identify stack of infrastructure components"
  default     = "default"
}

variable "detail" {
  description = "The extra description of module instance"
  default     = ""
}

### security
variable "assume_role_arn" {
  description = "The list of ARNs of target AWS role that you want to manage with spinnaker. e.g.,) arn:aws:iam::12345678987:role/spinnakerManaged"
  default     = []
  type        = list(string)
}
