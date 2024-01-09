### default values

### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  default_helm = {
    name              = "spin"
    repository        = join("/", [path.module, "charts"])
    chart_name        = "spinnaker"
    chart_version     = null
    namespace         = "spinnaker"
    timeout           = "500"
    cleanup_on_fail   = true
    dependency_update = true
  }
  default_eks_cluster = {
    version      = "1.24"
    ssm_enabled  = false
    cluster_logs = []
  }
  default_eks_node_group = {
    name          = "cd"
    instance_type = "m5.xlarge"
    min_size      = "1"
    max_size      = "3"
    desired_size  = "1"
    ### A list of ARNs of spinnaker-managed IAM role
    ### This is an example: (arn:aws:iam::12345678987:role/spinnakerManaged)
    role_arns = []
  }
  default_s3_bucket = {
    force_destroy = false
    versioning    = "Enabled"
  }
  default_aurora_cluster = {
    engine            = "aurora-mysql"
    family            = "aurora-mysql8.0"
    version           = "8.0.mysql_aurora.3.01.0"
    port              = "3306"
    apply_immediately = "true"
    cluster_parameters = {
      character_set_server = "utf8"
      character_set_client = "utf8"
    }
  }
  default_aurora_instance = {
    instance_type = "db.r6g.large"
  }
}
