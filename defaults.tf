### default values

locals {
  default_helm_config = {
    name            = "cd"
    repository      = "https://kubernetes-charts.storage.googleapis.com"
    chart           = "spinnaker"
    version         = "2.2.2"
    namespace       = "spinnaker"
    timeout         = "500"
    cleanup_on_fail = "true"
    values          = join("/", [path.module, "values.yaml"])
  }
}
