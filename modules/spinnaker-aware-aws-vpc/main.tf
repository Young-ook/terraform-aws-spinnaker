## virtual private cloud

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.default-tags,
    { Name = local.name },
    var.tags,
  )
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
locals {
  vpc_endpoint_config  = var.vpc_endpoint_config == null ? local.default_vpc_endpoint_config : var.vpc_endpoint_config
  vpc_endpoint_enabled = length(local.vpc_endpoint_config) > 0 ? true : false
}

data "aws_vpc_endpoint_service" "vpce" {
  for_each     = { for ep in local.vpc_endpoint_config : ep.service => ep if local.vpc_endpoint_enabled }
  service      = each.key == "notebook" ? null : each.key
  service_name = each.key == "notebook" ? format("aws.sagemaker.%s.notebook", data.aws_region.current.name) : null
  service_type = lookup(each.value, "type", "Gateway")
}

# How to use matchkey function (https://www.terraform.io/docs/language/functions/matchkeys.html)
# This matchkey function pick subnet IDs up where VPC endpoints are available
resource "aws_vpc_endpoint" "vpce" {
  for_each          = { for ep in local.vpc_endpoint_config : ep.service => ep if local.vpc_endpoint_enabled }
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
  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "private", "vpce", each.key]) },
    var.tags,
  )
}

### public subnet
resource "aws_subnet" "private" {
  for_each                = toset(var.azs)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = each.value
  cidr_block              = cidrsubnet(var.cidr, 8, (index(var.azs, each.value) * 8) + 1)
  map_public_ip_on_launch = true

  tags = merge(
    local.default-tags,
    { Name = join(".", [local.name, "private", each.value]) },
    { "kubernetes.io/role/internal-elb" = "1" },
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
  for_each = var.enable_ngw && var.single_ngw ? toset(list(local.selected_az)) : toset(var.azs)
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
  route_table_id = var.enable_ngw && var.single_ngw ? aws_route_table.private[local.selected_az].id : aws_route_table.private[each.key].id
}

resource "aws_route" "private_ngw" {
  for_each               = var.enable_ngw ? (var.single_ngw ? toset(list(local.selected_az)) : toset(var.azs)) : toset([])
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[each.value].id

  timeouts {
    create = "5m"
  }
}

# nat gateway
resource "aws_eip" "ngw" {
  for_each = var.enable_ngw ? (var.single_ngw ? toset(tolist(local.selected_az)) : toset(var.azs)) : toset([])
  vpc      = true
}

resource "aws_nat_gateway" "ngw" {
  depends_on    = [aws_eip.ngw, aws_subnet.public, aws_internet_gateway.igw]
  for_each      = var.enable_ngw ? (var.single_ngw ? toset(list(local.selected_az)) : toset(var.azs)) : toset([])
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
  for_each          = var.enable_igw ? toset(var.azs) : toset([])
  vpc_id            = aws_vpc.vpc.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.cidr, 8, (index(var.azs, each.value) * 8) + 2)

  tags = merge(
    local.default-tags,
    { Name = join(".", [local.name, "public", each.value]) },
    { "kubernetes.io/role/elb" = "1" },
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "public" {
  count  = var.enable_igw ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "public", "rt"]) },
    var.tags,
  )
}

resource "aws_route_table_association" "public" {
  for_each       = var.enable_igw ? toset(var.azs) : toset([])
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.0.id
}

resource "aws_route" "public_igw" {
  count                  = var.enable_igw ? 1 : 0
  route_table_id         = aws_route_table.public.0.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.0.id

  timeouts {
    create = "5m"
  }
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  count  = var.enable_igw ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.default-tags,
    { Name = join("-", [local.name, "igw"]) },
    var.tags,
  )
}
