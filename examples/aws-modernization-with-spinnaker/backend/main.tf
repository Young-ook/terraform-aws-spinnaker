### terraform remote state backend

module "tfstate" {
  source  = "Young-ook/tfstate-backend/aws"
  version = "1.0.2"
  name    = var.name
  tags    = var.tags
}
