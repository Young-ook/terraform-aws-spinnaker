### output variables

output "role" {
  description = "The IAM role for Spinnaker"
  value       = module.eks.role.managed_node_groups
}

locals {
  helm_chart_name   = nonsensitive(module.helm.addons.chart["spinnaker"].chart)
  helm_release_name = nonsensitive(module.helm.addons.chart["spinnaker"].name)
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
  value = join(" ", [
    "bash -e",
    format("%s/scripts/halconfig.sh", path.module),
    format("-r %s", module.aws.region.name),
    format("-n %s", module.eks.cluster.name),
    format("-p %s", local.halyard_pod),
    "-k kubeconfig",
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
