### output variables

output "role" {
  description = "IAM role for Spinnaker"
  value       = module.irsa.arn
}

locals {
  helm_chart_name   = nonsensitive(module.helm.addons.chart["spin"].chart)
  helm_release_name = nonsensitive(module.helm.addons.chart["spin"].name)
  halyard_pod       = join("-", [local.helm_release_name, "halyard-0"])
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

output "irsaconfig" {
  description = "Bash command to apply irsa annotations"
  value       = module.irsa.kubecli
}

output "features" {
  description = "Feature configurations of spinnaker"
  value = {
    "aurora_enabled" = local.aurora_enabled
    "s3_enabled"     = local.s3_enabled
    "ssm_enabled"    = local.ssm_enabled
  }
}
