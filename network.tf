## virtual private cloud

# vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = merge(
    local.vpc-name-tag,
    local.vpc-k8s-shared-tag,
    var.tags,
  )
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.igw-name-tag,
    var.tags,
  )
}

# nat gateway
resource "aws_eip" "ngw" {
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = element(compact(aws_subnet.public.*.id), 0)

  tags = merge(
    local.ngw-name-tag,
    var.tags,
  )

  depends_on = [
    aws_eip.ngw,
    aws_subnet.public,
  ]
}

# public subnets
resource "aws_subnet" "public" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(var.azs, count.index)
  cidr_block              = cidrsubnet(var.cidr, 8, 8 * count.index)
  map_public_ip_on_launch = "true"

  tags = merge(
    { "Name" = join(".", [local.name, "public", element(var.azs, count.index)]) },
    local.vpc-k8s-shared-tag,
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

# private subnets
resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(var.azs, count.index)
  cidr_block        = cidrsubnet(var.cidr, 8, 7 * (1 + count.index))

  tags = merge(
    { "Name" = join(".", [local.name, "private", element(var.azs, count.index)]) },
    local.vpc-k8s-shared-tag,
    var.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

# route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.public-route-name-tag,
    var.tags,
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.private-route-name-tag,
    var.tags,
  )
}

resource "aws_route" "route-igw" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "route-ngw" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.azs)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# vpc endpoints
data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = data.aws_vpc_endpoint_service.s3.service_name
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.private.id
}

## hosted zone of internal dns
resource "aws_route53_zone" "vpc" {
  name = var.dns_zone
  tags = merge(
    local.private-dns-name-tag,
    var.tags,
  )

  vpc {
    vpc_id = aws_vpc.vpc.id
  }
}
