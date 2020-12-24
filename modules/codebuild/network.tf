## virtual private cloud

# vpc
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_groups" "default" {
  filter {
    name   = "group-name"
    values = ["*default*"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  default_vpc_id = data.aws_vpc.default.id
  vpc_id         = local.default_vpc_id

  default_subnet_ids = data.aws_subnet_ids.default.ids
  subnet_ids         = local.default_subnet_ids

  default_security_groups_ids = data.aws_security_groups.default.ids
  security_groups_ids         = local.default_security_groups_ids
}
