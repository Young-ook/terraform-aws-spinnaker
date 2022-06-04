module "aws-partitions" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

## spinnaker configuration
resource "local_file" "halconfig" {
  content = templatefile("${path.module}/templates/halconfig.tpl", {
    aws_account_id              = module.aws-partitions.caller.account_id
    aws_region                  = module.aws-partitions.region.name
    spinnaker_version           = var.spinnaker_version
    spinnaker_managed_aws_role  = module.spinnaker-managed.role_arn
    spinnaker_update_kubeconfig = module.spinnaker.kubeconfig
    eks_update_kubeconfig       = var.eks["script"]
    eks_kubeconfig_context      = var.eks["cluster"].name
    halyard_kubectl_exec        = "kubectl -n spinnaker exec -it cd-spinnaker-halyard-0 --"
  })
  filename        = "${path.cwd}/halconfig.sh"
  file_permission = "0700"
}

resource "local_file" "tunnel" {
  content = join("\n", [
    "#!/bin/bash -ex",
    "export KUBECONFIG=spinnaker_kubeconfig",
    "kubectl -n spinnaker port-forward svc/spin-deck 8080:9000",
    ]
  )
  filename        = "${path.cwd}/tunnel.sh"
  file_permission = "0700"
}

resource "local_file" "preuninstall" {
  content = templatefile("${path.module}/templates/preuninstall.tpl", {
    aws_region             = module.aws-partitions.region.name
    eks_update_kubeconfig  = var.eks["script"]
    eks_kubeconfig_context = var.eks["cluster"].name
  })
  filename        = "${path.cwd}/preuninstall.sh"
  file_permission = "0700"
}
