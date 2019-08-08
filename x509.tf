# x509 certificates for spinnaker cli and helm/tiller communication

# x509 certificates authority
data "template_file" "x509" {
  template = file(format("%s/res/x509.tpl", path.module))

  vars = {
    country      = lookup(var.x509_prop, "country", "KR")
    state        = lookup(var.x509_prop, "country", "SEL")
    location     = lookup(var.x509_prop, "country", "SEL")
    organization = lookup(var.x509_prop, "country", "ORG")
    common_name  = lookup(var.x509_prop, "common_name", "your@email.com")
    groups       = lookup(var.x509_prop, "groups", "admin")
  }
}

resource "local_file" "gen-x509-ca" {
  content  = data.template_file.x509.rendered
  filename = format("%s/%s/gen-x509.sh", path.cwd, local.cluster-name)
}
