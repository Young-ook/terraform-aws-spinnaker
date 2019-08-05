# aurora-mysql

### security/firewall
resource "random_string" "password" {
  length           = 16
  special          = true
  override_special = "^"
}

resource "aws_security_group" "db" {
  name        = "local.name-db"
  description = "security group for local.name-db"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    map("Name", "local.name-db"),
  var.tags)
}

resource "aws_security_group_rule" "db-ingress-rules" {
  type                     = "ingress"
  from_port                = var.mysql_port
  to_port                  = var.mysql_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = aws_security_group.db.id
}

# subnet group
resource "aws_db_subnet_group" "db" {
  name       = "local.name-db"
  subnet_ids = aws_subnet.private.*.id
  tags       = merge(map("Name", "local.name-db"), var.tags)
}

# parameter groups
resource "aws_rds_cluster_parameter_group" "db" {
  name = format("%s-db-cluster-params", local.name)

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
  name = format("%s-db-params", local.name)

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
  cluster_identifier_prefix       = format("%s-", local.cluster-name)
  engine                          = "aurora-mysql"
  engine_version                  = var.mysql_version
  engine_mode                     = "provisioned"
  port                            = var.mysql_port
  skip_final_snapshot             = "true"
  database_name                   = var.mysql_db
  master_username                 = var.mysql_master_user
  master_password                 = random_string.password.result
  snapshot_identifier             = var.mysql_snapshot
  backup_retention_period         = "5"
  db_subnet_group_name            = aws_db_subnet_group.db.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db.name
  vpc_security_group_ids          = [aws_security_group.db.id]
  tags                            = merge(map("Name", "local.name-db"), var.tags)

  lifecycle {
    ignore_changes        = ["snapshot_identifier", "master_password"]
    create_before_destroy = true
  }
}

# rds instances
resource "aws_rds_cluster_instance" "db" {
  count                   = var.mysql_node_count
  identifier              = format("%s-%d", local.cluster-name, count.index)
  cluster_identifier      = aws_rds_cluster.db.id
  instance_class          = var.mysql_node_type
  engine                  = "aurora-mysql"
  engine_version          = var.mysql_version
  db_parameter_group_name = aws_db_parameter_group.db.name
  db_subnet_group_name    = aws_db_subnet_group.db.name
}

# dns records
resource "aws_route53_record" "db" {
  zone_id = aws_route53_zone.vpc.zone_id
  name    = "local.cluster-name-db.var.dns_zone"
  type    = "CNAME"
  ttl     = 300
  records = coalescelist(aws_rds_cluster.db.*.endpoint, list(""))
}
