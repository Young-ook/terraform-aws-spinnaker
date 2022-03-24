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
    eks_update_kubeconfig       = var.eks_kubeconfig["script"]
    eks_kubeconfig_context      = var.eks_kubeconfig["context"]
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
    eks_update_kubeconfig  = var.eks_kubeconfig["script"]
    eks_kubeconfig_context = var.eks_kubeconfig["context"]
  })
  filename        = "${path.cwd}/preuninstall.sh"
  file_permission = "0700"
}

## fault injection experiment templates
resource "local_file" "disk-stress" {
  content = templatefile("${path.module}/templates/disk-stress.tpl", {
    doc_arn = aws_ssm_document.disk-stress.arn
    alarm   = aws_cloudwatch_metric_alarm.disk.arn
    role    = aws_iam_role.fis-run.arn
  })
  filename        = "${path.cwd}/disk-stress.json"
  file_permission = "0600"
}

resource "local_file" "create-templates" {
  content = join("\n", [
    "#!/bin/bash",
    "OUTPUT='.fis_cli_result'",
    "TEMPLATES=('disk-stress.json')",
    "for template in $${TEMPLATES[@]}; do",
    "  aws fis create-experiment-template --region ${var.aws_region} --cli-input-json file://$${template} --output text --query 'experimentTemplate.id' 2>&1 | tee -a $${OUTPUT}",
    "done",
    ]
  )
  filename        = "${path.cwd}/create-fis-tpl.sh"
  file_permission = "0600"
}

resource "null_resource" "create-templates" {
  depends_on = [
    local_file.disk-stress,
    local_file.create-templates,
  ]
  provisioner "local-exec" {
    when    = create
    command = "bash create-fis-tpl.sh"
  }
}

resource "local_file" "delete-templates" {
  content = join("\n", [
    "#!/bin/bash",
    "OUTPUT='.fis_cli_result'",
    "while read id; do",
    "  aws fis delete-experiment-template --region ${var.aws_region} --id $${id} --output text --query 'experimentTemplate.id' 2>&1 > /dev/null",
    "done < $${OUTPUT}",
    "rm $${OUTPUT}",
    ]
  )
  filename        = "${path.cwd}/delete-fis-tpl.sh"
  file_permission = "0600"
}

resource "null_resource" "delete-templates" {
  depends_on = [
    local_file.disk-stress,
    local_file.delete-templates,
  ]
  provisioner "local-exec" {
    when    = destroy
    command = "bash delete-fis-tpl.sh"
  }
}
