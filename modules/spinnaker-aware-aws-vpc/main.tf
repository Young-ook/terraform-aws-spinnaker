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

### isolated subnet
resource "aws_subnet" "isolated" {
  for_each          = toset(var.azs)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.cidr, 8, (index(var.azs, each.value) * 8))

  tags = merge(
    local.default-tags,
    { Name = join(".", [local.name, "isolated", each.value]) },
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "isolated" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "isolated", "rt"]) },
    var.tags,
  )
}

resource "aws_route_table_association" "isolated" {
  for_each       = toset(var.azs)
  subnet_id      = aws_subnet.isolated[each.key].id
  route_table_id = aws_route_table.isolated.id
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
    values(local.isolated_subnets),
    keys(local.isolated_subnets),
    data.aws_vpc_endpoint_service.vpce[each.key].availability_zones
  ) : null
  security_group_ids  = lookup(each.value, "type") == "Interface" ? [aws_security_group.vpce.id] : null
  private_dns_enabled = lookup(each.value, "private_dns_enabled", false)
  policy              = lookup(each.value, "policy", null)
  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "isolated", "vpce", each.key]) },
    var.tags,
  )
}

### public subnet
resource "aws_subnet" "private" {
  for_each          = toset(var.azs)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.cidr, 8, (index(var.azs, each.value) * 8) + 1)

  tags = merge(
    local.default-tags,
    { Name = join(".", [local.name, "private", each.value]) },
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  selected_az = var.azs[0]
}

resource "aws_route_table" "private" {
  for_each = var.single_ngw ? toset(list(local.selected_az)) : toset(var.azs)
  vpc_id   = aws_vpc.vpc.id

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "private", "rt"]) },
    var.tags,
  )
}

resource "aws_route_table_association" "private" {
  for_each       = toset(var.azs)
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = var.single_ngw ? aws_route_table.private[local.selected_az].id : aws_route_table.private[each.key].id
}

resource "aws_route" "private_ngw" {
  for_each               = var.single_ngw ? toset(list(local.selected_az)) : toset(var.azs)
  route_table_id         = var.single_ngw ? aws_route_table.private[local.selected_az].id : aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[each.value].id

  timeouts {
    create = "5m"
  }
}

# nat gateway
resource "aws_eip" "ngw" {
  for_each = var.single_ngw ? toset(list(local.selected_az)) : toset(var.azs)
  vpc      = true
}

resource "aws_nat_gateway" "ngw" {
  depends_on    = [aws_eip.ngw, aws_subnet.public, aws_internet_gateway.igw]
  for_each      = var.single_ngw ? toset(list(local.selected_az)) : toset(var.azs)
  allocation_id = aws_eip.ngw[each.key].id
  subnet_id     = local.public_subnets[each.key]

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "ngw", each.key]) },
    var.tags,
  )
}

### public subnet
resource "aws_subnet" "public" {
  for_each          = toset(var.azs)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.cidr, 8, (index(var.azs, each.value) * 8) + 2)

  tags = merge(
    local.default-tags,
    { Name = join(".", [local.name, "public", each.value]) },
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "public", "rt"]) },
    var.tags,
  )
}

resource "aws_route_table_association" "public" {
  for_each       = toset(var.azs)
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  timeouts {
    create = "5m"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "igw"]) },
    var.tags,
  )
}
