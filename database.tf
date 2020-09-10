module "db" {
  source = "./modules/aurora"

  name             = local.name
  vpc              = aws_vpc.vpc.id
  subnets          = aws_subnet.private.*.id
  cidrs            = [aws_vpc.vpc.cidr_block]
  aurora_cluster   = var.aurora_cluster
  aurora_instances = var.aurora_instances
}
