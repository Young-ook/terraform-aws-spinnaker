### terraform remote state backend

module "tfstate" {
  source        = "Young-ook/tfstate/aws"
  version       = "2.0.0"
  name          = var.name
  tags          = var.tags
  force_destroy = true
}
