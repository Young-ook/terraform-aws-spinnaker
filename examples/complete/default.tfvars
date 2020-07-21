aws_account_id     = "YOUR_AWS_ACCOUNT"
aws_region         = "ap-northeast-2"
name               = "spin"
stack              = "dev"
azs                = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
tags               = { "env" = "dev" }
dns_zone           = "your.private"
kube_version       = "1.16"
kube_node_type     = "t3.medium"
kube_node_size     = "1"
kube_node_vol_size = "8"
mysql_version      = "5.7.12"
mysql_node_type    = "db.t3.medium"
mysql_node_size    = "1"
