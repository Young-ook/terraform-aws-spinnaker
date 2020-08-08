
###
# Be careful! You can accidentally lock yourself out of your project using this resource. 
#
# PROCEED with CAUTION. 
#
# It's not recommended to use google_project_iam_policy with your provider project
# to avoid locking yourself out, and it should generally only be used with projects 
# fully managed by Terraform.
###

# spinnaker managed
resource "google_service_account" "spinnaker-managed" {
  account_id   = local.name
  display_name = "spinnaker service account"
}

resource "google_service_account_key" "spinnaker-managed" {
  service_account_id = google_service_account.spinnaker-managed.name
}

data "google_service_account_key" "spinnaker-managed" {
  name            = google_service_account_key.spinnaker-managed.name
  public_key_type = "TYPE_X509_PEM_FILE"
}

resource "local_file" "credential" {
  content  = base64decode(google_service_account_key.spinnaker-managed.private_key)
  filename = format("%s/%s", path.cwd, local.credential_json)
}

resource "null_resource" "chmod" {
  depends_on = [local_file.credential]
  provisioner "local-exec" {
    command     = format("chmod 600 %s", local.credential_json)
    working_dir = path.cwd
    interpreter = ["bash", "-c"]
  }
}

# list of roles which spinnaker service account must has
variable "spinnaker-managed-roles" {
  default = [
    "roles/compute.instanceAdmin.v1",
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/compute.storageAdmin",
    "roles/iam.serviceAccountUser",
  ]
}

# roles and account mapping
resource "google_project_iam_member" "spinnaker-managed" {
  count   = length(var.spinnaker-managed-roles)
  project = var.project
  role    = var.spinnaker-managed-roles[count.index]
  member  = format("serviceAccount:%s", google_service_account.spinnaker-managed.email)
}
