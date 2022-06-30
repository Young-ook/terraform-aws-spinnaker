### terraform remote state backend

module "tfstate" {
  source        = "Young-ook/tfstate-backend/aws"
  version       = "1.0.3"
  name          = var.name
  tags          = var.tags
  force_destroy = true
}
