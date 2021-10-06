### default values

locals {
  default_helm_config = {
    name              = "cd"
    repository        = join("/", [path.module])
    chart             = "helm-chart"
    namespace         = "spinnaker"
    timeout           = "500"
    cleanup_on_fail   = true
    dependency_update = true
  }
  default_s3_bucket_config = {
    force_destroy   = false
    versioning      = true
    lifecycle_rules = []
  }
}
