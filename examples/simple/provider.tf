terraform {
  required_version = "~> 0.12.0"

  backend "s3" {
    bucket         = "terraform-state"
    key            = "path/to/terraform.tfstate"
    region         = var.aws_region
    profile        = var.aws_profile
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region              = var.aws_region
  profile             = var.aws_profile
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 1.21.0"
}
