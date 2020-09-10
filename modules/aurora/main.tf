## aurora cluster

# condition
locals {
  enabled = var.aurora_cluster != null ? true : false
}

# security/password
resource "random_password" "password" {
  count            = local.enabled ? 1 : 0
  length           = 16
  special          = true
  override_special = "^"
}

# security/firewall
resource "aws_security_group" "db" {
  count       = local.enabled ? 1 : 0
  name        = format("%s-db", var.name)
  description = format("security group for %s-db", var.name)
  vpc_id      = var.vpc
  tags        = merge(local.default-tags, var.tags)
}

resource "aws_security_group_rule" "db-ingress-rules" {
  count             = local.enabled ? 1 : 0
  type              = "ingress"
  from_port         = lookup(var.aurora_cluster, "port", "3306")
  to_port           = lookup(var.aurora_cluster, "port", "3306")
  protocol          = "tcp"
  cidr_blocks       = var.cidrs
  security_group_id = aws_security_group.db[0].id
}

# subnet group
resource "aws_db_subnet_group" "db" {
  count      = local.enabled ? 1 : 0
  name       = format("%s-db", var.name)
  subnet_ids = var.subnets
  tags       = merge(local.default-tags, var.tags)
}

# parameter groups
resource "aws_rds_cluster_parameter_group" "db" {
  count = local.enabled ? 1 : 0
  name  = format("%s-db-cluster-params", var.name)

  family = format("%s%s.%s",
    lookup(var.aurora_cluster, "engine", "aurora-mysql"),
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
  count = local.enabled ? 1 : 0
  name  = format("%s-db-params", var.name)

  family = format("%s%s.%s",
    lookup(var.aurora_cluster, "engine", "aurora-mysql"),
    element(split(".", lookup(var.aurora_cluster, "version", "5.7.12")), 0),
    element(split(".", lookup(var.aurora_cluster, "version", "5.7.12")), 1)
  )

  lifecycle {
    create_before_destroy = true
  }
}

# rds cluster
resource "aws_rds_cluster" "db" {
  count                           = local.enabled ? 1 : 0
  cluster_identifier_prefix       = format("%s-", var.name)
  engine                          = lookup(var.aurora_cluster, "engine", "aurora-mysql")
  engine_mode                     = "provisioned"
  engine_version                  = lookup(var.aurora_cluster, "version", "5.7.12")
  port                            = lookup(var.aurora_cluster, "port", "3306")
  skip_final_snapshot             = "true"
  database_name                   = lookup(var.aurora_cluster, "database", "yourdb")
  master_username                 = lookup(var.aurora_cluster, "user", "yourid")
  master_password                 = random_password.password[0].result
  snapshot_identifier             = lookup(var.aurora_cluster, "snapshot_id", "")
  backup_retention_period         = lookup(var.aurora_cluster, "backup_retention", "5")
  db_subnet_group_name            = aws_db_subnet_group.db[0].name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db[0].name
  vpc_security_group_ids          = coalescelist(aws_security_group.db.*.id, [])
  tags                            = merge(local.default-tags, var.tags)

  lifecycle {
    ignore_changes        = [snapshot_identifier, master_password]
    create_before_destroy = true
  }
}

# rds instances
resource "aws_rds_cluster_instance" "db" {
  for_each                = (local.enabled ? var.aurora_instances : {})
  identifier              = each.key
  cluster_identifier      = element(aws_rds_cluster.db.*.id, 0)
  engine                  = lookup(var.aurora_cluster, "engine", "aurora-mysql")
  engine_version          = lookup(var.aurora_cluster, "version", "5.7.12")
  instance_class          = lookup(each.value, "node_type", "db.t3.medium")
  db_parameter_group_name = aws_db_parameter_group.db[0].name
  db_subnet_group_name    = aws_db_subnet_group.db[0].name
  apply_immediately       = tobool(lookup(var.aurora_cluster, "apply_immedidately", "false"))
  tags                    = merge(local.default-tags, var.tags)
}
