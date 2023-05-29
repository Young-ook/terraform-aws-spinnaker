### output variables

output "role" {
  description = "The IAM role for Spinnaker"
  value       = module.eks.role
}

locals {
  helm_chart_name   = helm_release.spinnaker.chart
  helm_release_name = helm_release.spinnaker.name
  halyard_pod = (
    local.helm_chart_name == local.helm_release_name ? (
      join("-", [local.helm_chart_name, "halyard-0"])
      ) : (
      join("-", [local.helm_release_name, local.helm_chart_name, "halyard-0"])
    )
  )
}

output "halconfig" {
  description = "Bash command to access halyard in interactive mode"
  value = join("\n", [
    module.eks.kubeconfig,
    "export KUBECONFIG=kubeconfig",
    "kubectl -n spinnaker exec -it ${local.halyard_pod} -- bash",
  ])
}

output "features" {
  description = "Feature configurations of spinnaker"
  value = {
    "aurora_enabled" = local.aurora_enabled
    "s3_enabled"     = local.s3_enabled
    "ssm_enabled"    = local.ssm_enabled
  }
}
