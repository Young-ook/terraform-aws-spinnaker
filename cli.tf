# cli.tf
# spinnaker cli certificate authorities

# kube config
data "template_file" "cli_x509" {
  template = "${file("${path.module}/res/cli-x509.tpl")}"
}

resource "local_file" "gen_x509_ca" {
  content  = "${data.template_file.cli_x509.rendered}"
  filename = "${path.cwd}/${local.cluster_name}/gen-x509.sh"
}
