# Variables for providing to module fixture codes

### aws credential
variable "aws_account_id" {
  description = "The aws account id for the tf backend creation (e.g. 857026751867)"
}

### network
variable "aws_region" {
  description = "The aws region to deploy the service into"
  type        = string
  default     = "us-east-1"
}

### security
variable "trusted_role_arn" {
  description = "A list of full arn of iam roles of spinnaker cluster"
  type        = list(string)
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
