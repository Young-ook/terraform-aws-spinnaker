## virtual private cloud

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = merge(
    local.default-tags,
    var.tags,
  )
}

resource "aws_subnet" "private" {
  for_each          = toset(var.azs)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.cidr, 8, 7 * (index(var.azs, each.value) + 1))

  tags = merge(
    local.default-tags,
    { Name = join(".", [local.name, "private", each.value]) },
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "private", "rt"]) },
    var.tags,
  )
}

resource "aws_route_table_association" "private" {
  for_each       = toset(var.azs)
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}

# security/firewall
resource "aws_security_group" "vpce" {
  name        = format("%s-%s", local.name, "vpce")
  description = format("security group for vpc endpoint of %s", local.name)
  vpc_id      = aws_vpc.vpc.id
  tags        = var.tags

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  #  egress {
  #    from_port   = 0
  #    to_port     = 0
  #    protocol    = "-1"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }
}

## aws partition and region (global, gov, china)
data "aws_region" "current" {}

# vpc endpoint
# For AWS services the service name is usually in the form com.amazonaws.<region>.<service>
# The SageMaker Notebook service is an exception to this rule, the service name is in the form 
# aws.sagemaker.<region>.notebook.
data "aws_vpc_endpoint_service" "vpce" {
  for_each     = { for ep in local.default_vpc_endpoint_config : ep.service => ep if var.enabled }
  service      = each.key == "notebook" ? null : each.key
  service_name = each.key == "notebook" ? format("aws.sagemaker.%s.notebook", data.aws_region.current.name) : null
  service_type = lookup(each.value, "type", "Gateway")
}

# How to use matchkey function (https://www.terraform.io/docs/language/functions/matchkeys.html)
# This matchkey function pick subnet IDs up where VPC endpoints are available
resource "aws_vpc_endpoint" "vpce" {
  for_each          = { for ep in local.default_vpc_endpoint_config : ep.service => ep if var.enabled }
  service_name      = data.aws_vpc_endpoint_service.vpce[each.key].service_name
  vpc_endpoint_type = lookup(each.value, "type", "Gateway")
  vpc_id            = aws_vpc.vpc.id
  subnet_ids = lookup(each.value, "type") == "Interface" ? matchkeys(
    values(local.private_subnets),
    keys(local.private_subnets),
    data.aws_vpc_endpoint_service.vpce[each.key].availability_zones
  ) : null
  security_group_ids  = lookup(each.value, "type") == "Interface" ? [aws_security_group.vpce.id] : null
  private_dns_enabled = lookup(each.value, "private_dns_enabled", false)
  policy              = lookup(each.value, "policy", null)
  tags                = merge(local.default-tags, var.tags)
}
