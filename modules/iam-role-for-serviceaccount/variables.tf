variable "namespace" {
  description = "The namespace where kubernetes service account is"
  type        = string
}

variable "serviceaccount" {
  description = "The name of kubernetes service account"
  type        = string
}

### security
variable "policy_arns" {
  description = "A list of policy ARNs to attach the role"
  type        = list(string)
  default     = []
}

variable "oidc_url" {
  description = "A URL of the OIDC Provider"
  type        = string
}

variable "oidc_arn" {
  description = "An ARN of the OIDC Provider"
  type        = string
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
