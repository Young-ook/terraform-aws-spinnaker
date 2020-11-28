name   = "spinnaker"
stack  = "dev"
detail = "tc1"
tags = {
  env  = "dev"
  test = "tc1"
}
aws_region         = "ap-northeast-2"
azs                = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
cidr               = "10.0.0.0/16"
kubernetes_version = "1.17"
kubernetes_node_groups = [
  {
    name          = "default"
    instance_type = "m5.large"
    min_size      = "1"
    max_size      = "3"
    desired_size  = "2"
  }
]
aurora_cluster = {
  engine            = "aurora-mysql"
  version           = "5.7.mysql_aurora.2.07.2"
  port              = "3306"
  backup_retention  = "1"
  apply_immediately = "true"
  cluster_parameters = {
    character_set_server = "utf8"
    character_set_client = "utf8"
  }
}
aurora_instances = [
  {
    instance_type = "db.t3.medium"
  }
]
