# spinnaker cli certificate authorities

# kube config
data "template_file" "x509" {
  template = file("${path.module}/res/x509.tpl")
}

resource "local_file" "gen-x509-ca" {
  content  = data.template_file.x509.rendered
  filename = "${path.cwd}/${local.cluster-name}/gen-x509.sh"
}

