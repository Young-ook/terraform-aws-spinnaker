# helm variables
locals {
  default_helm_config = {
    "repo"      = "https://kubernetes-charts.storage.googleapis.com"
    "version"   = "2.1.0-rc.1"
    "timeout"   = "600"
    "namespace" = "spinnaker"
    "values"    = yamlencode({})
  }
}
