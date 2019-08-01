# spinnaker cli certificate authorities

# kube config
data "template_file" "cli-x509" {
  template = file("${path.module}/res/cli-x509.tpl")
}

resource "local_file" "gen-x509-ca" {
  content  = data.template_file.cli-x509.rendered
  filename = "${path.cwd}/${local.cluster-name}/gen-x509.sh"
}

