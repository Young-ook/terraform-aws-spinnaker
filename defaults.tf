### default values

locals {
  default_helm_config = {
    name              = "cd"
    repository        = join("/", [path.module])
    values            = join("/", [path.module, "helm-chart", "values.yaml"])
    chart             = "helm-chart"
    namespace         = "spinnaker"
    timeout           = "500"
    cleanup_on_fail   = true
    dependency_update = true
  }
}
