# output variables 

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
