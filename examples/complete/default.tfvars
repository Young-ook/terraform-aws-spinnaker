aws_account_id     = "YOUR_AWS_ACCOUNT"
aws_region         = "ap-northeast-2"
name               = "spin"
stack              = "dev"
azs                = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
tags               = { "env" = "dev" }
dns_zone           = "your.private"
kubernetes_version = "1.16"
kubernetes_node_groups = {
  "default" = {
    "instance_type" = "m5.large"
    "min_size"      = "1"
    "max_size"      = "3"
    "desired_size"  = "2"
  }
}
mysql_version    = "5.7.12"
mysql_node_type  = "db.t3.medium"
mysql_node_size  = "1"
helm_values_file = "helm-values.yml"
