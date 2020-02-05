## aurora cluster for orca-mysql

# security/password
resource "random_password" "password" {
  count            = (var.mysql_node_size > 0) ? 1 : 0
  length           = 16
  special          = true
  override_special = "^"
}

# security/firewall
resource "aws_security_group" "db" {
  count       = (var.mysql_node_size > 0) ? 1 : 0
  name        = format("%s-db", local.name)
  description = format("security group for %s-db", local.name)
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(map("Name", format("%s-db", local.name)), var.tags)
}

resource "aws_security_group_rule" "db-ingress-rules" {
  count                    = (var.mysql_node_size > 0) ? 1 : 0
  type                     = "ingress"
  from_port                = var.mysql_port
  to_port                  = var.mysql_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = aws_security_group.db[0].id
}

# subnet group
resource "aws_db_subnet_group" "db" {
  count      = (var.mysql_node_size > 0) ? 1 : 0
  name       = format("%s-db", local.name)
  subnet_ids = aws_subnet.private.*.id
  tags       = merge(map("Name", format("%s-db", local.name)), var.tags)
}

# parameter groups
resource "aws_rds_cluster_parameter_group" "db" {
  count = (var.mysql_node_size > 0) ? 1 : 0
  name  = format("%s-db-cluster-params", local.name)

  family = format("aurora-mysql%s.%s",
    element(split(".", var.mysql_version), 0),
    element(split(".", var.mysql_version), 1)
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
  count = (var.mysql_node_size > 0) ? 1 : 0
  name  = format("%s-db-params", local.name)

  family = format("aurora-mysql%s.%s",
    element(split(".", var.mysql_version), 0),
    element(split(".", var.mysql_version), 1)
  )

  lifecycle {
    create_before_destroy = true
  }
}

# rds (aurora)
resource "aws_rds_cluster" "db" {
  count                           = (var.mysql_node_size > 0) ? 1 : 0
  cluster_identifier_prefix       = format("%s-", local.cluster-name)
  engine                          = "aurora-mysql"
  engine_mode                     = "provisioned"
  engine_version                  = var.mysql_version
  port                            = var.mysql_port
  skip_final_snapshot             = "true"
  database_name                   = var.mysql_db
  master_username                 = var.mysql_master_user
  master_password                 = random_password.password[0].result
  snapshot_identifier             = var.mysql_snapshot
  backup_retention_period         = "5"
  db_subnet_group_name            = aws_db_subnet_group.db[0].name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db[0].name
  vpc_security_group_ids          = coalescelist(aws_security_group.db.*.id, list(""))
  tags                            = merge(map("Name", format("%s-db", local.name)), var.tags)

  lifecycle {
    ignore_changes        = [snapshot_identifier, master_password]
    create_before_destroy = true
  }
}

# rds instances
resource "aws_rds_cluster_instance" "db" {
  count                   = var.mysql_node_size
  identifier              = format("%s-%s", local.cluster-name, count.index)
  cluster_identifier      = aws_rds_cluster.db[0].id
  instance_class          = var.mysql_node_type
  engine                  = "aurora-mysql"
  engine_version          = var.mysql_version
  db_parameter_group_name = aws_db_parameter_group.db[0].name
  db_subnet_group_name    = aws_db_subnet_group.db[0].name
  apply_immediately       = var.mysql_apply_immediately
}

# dns records
resource "aws_route53_record" "db" {
  count   = (var.mysql_node_size > 0) ? 1 : 0
  zone_id = aws_route53_zone.vpc.zone_id
  name    = format("%s-db.%s", local.cluster-name, var.dns_zone)
  type    = "CNAME"
  ttl     = 300
  records = coalescelist(aws_rds_cluster.db.*.endpoint, list(""))
}
