## aurora cluster

# condition
locals {
  cluster_count = (tonumber(lookup(var.aurora_cluster, "node_size", 0)) > 0) ? 1 : 0
}

# security/password
resource "random_password" "password" {
  count            = local.cluster_count
  length           = 16
  special          = true
  override_special = "^"
}

# security/firewall
resource "aws_security_group" "db" {
  count       = local.cluster_count
  name        = format("%s-db", local.name)
  description = format("security group for %s-db", local.name)
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(map("Name", format("%s-db", local.name)), var.tags)
}

resource "aws_security_group_rule" "db-ingress-rules" {
  count             = local.cluster_count
  type              = "ingress"
  from_port         = lookup(var.aurora_cluster, "port", "3306")
  to_port           = lookup(var.aurora_cluster, "port", "3306")
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.db[0].id
}

# subnet group
resource "aws_db_subnet_group" "db" {
  count      = local.cluster_count
  name       = format("%s-db", local.name)
  subnet_ids = aws_subnet.private.*.id
  tags       = merge(map("Name", format("%s-db", local.name)), var.tags)
}

# parameter groups
resource "aws_rds_cluster_parameter_group" "db" {
  count = local.cluster_count
  name  = format("%s-db-cluster-params", local.name)

  family = format("aurora-mysql%s.%s",
    element(split(".", lookup(var.aurora_cluster, "version", "5.7.12")), 0),
    element(split(".", lookup(var.aurora_cluster, "version", "5.7.12")), 1)
  )

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "db" {
  count = local.cluster_count
  name  = format("%s-db-params", local.name)

  family = format("aurora-mysql%s.%s",
    element(split(".", lookup(var.aurora_cluster, "version", "5.7.12")), 0),
    element(split(".", lookup(var.aurora_cluster, "version", "5.7.12")), 1)
  )

  lifecycle {
    create_before_destroy = true
  }
}

# rds (aurora)
resource "aws_rds_cluster" "db" {
  count                           = local.cluster_count
  cluster_identifier_prefix       = format("%s-", local.name)
  engine                          = "aurora-mysql"
  engine_mode                     = "provisioned"
  engine_version                  = lookup(var.aurora_cluster, "version", "5.7.12")
  port                            = lookup(var.aurora_cluster, "port", "3306")
  skip_final_snapshot             = "true"
  database_name                   = lookup(var.aurora_cluster, "database", "yourdb")
  master_username                 = lookup(var.aurora_cluster, "master_user", "yourid")
  master_password                 = random_password.password[0].result
  snapshot_identifier             = lookup(var.aurora_cluster, "snapshot_id", "")
  backup_retention_period         = lookup(var.aurora_cluster, "backup_retention", "5")
  db_subnet_group_name            = aws_db_subnet_group.db[0].name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db[0].name
  vpc_security_group_ids          = coalescelist(aws_security_group.db.*.id, [])
  tags                            = merge(map("Name", format("%s-db", local.name)), var.tags)

  lifecycle {
    ignore_changes        = [snapshot_identifier, master_password]
    create_before_destroy = true
  }
}

# rds instances
resource "aws_rds_cluster_instance" "db" {
  count                   = lookup(var.aurora_cluster, "node_size", 0)
  identifier              = join("-", [element(aws_rds_cluster.db.*.id, 0), count.index])
  cluster_identifier      = element(aws_rds_cluster.db.*.id, 0)
  engine                  = "aurora-mysql"
  engine_version          = lookup(var.aurora_cluster, "version", "5.7.12")
  instance_class          = lookup(var.aurora_cluster, "node_type", "db.t3.medium")
  db_parameter_group_name = aws_db_parameter_group.db[0].name
  db_subnet_group_name    = aws_db_subnet_group.db[0].name
  apply_immediately       = tobool(lookup(var.aurora_cluster, "apply_immedidately", "false"))
}

# dns records
resource "aws_route53_record" "db" {
  count   = local.cluster_count
  zone_id = aws_route53_zone.vpc.zone_id
  name    = format("%s-db.%s", local.name, var.dns_zone)
  type    = "CNAME"
  ttl     = 300
  records = coalescelist(aws_rds_cluster.db.*.endpoint, [])
}
