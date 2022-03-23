resource "local_file" "backend" {
  content         = module.tfstate.backend
  filename        = "${path.cwd}/backend.tf"
  file_permission = "0600"
}
