### default values

locals {
  default_kubernetes_node_groups = [
    {
      name          = "default"
      instance_type = "m5.large"
      min_size      = 1
      max_size      = 3
      desired_size  = 2
    }
  ]
  default_helm_config = {
    name              = "cd"
    repository        = join("/", [path.module, "charts"])
    chart             = "spinnaker"
    namespace         = "spinnaker"
    timeout           = "500"
    cleanup_on_fail   = true
    dependency_update = true
  }
  default_s3_bucket_config = {
    force_destroy   = false
    versioning      = "Enabled"
    lifecycle_rules = null
  }
}
