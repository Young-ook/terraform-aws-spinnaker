### default values

locals {
  default_eks_cluster = {
    version     = "1.24"
    ssm_enabled = false
  }
  default_eks_node_group = {
    name          = "cd"
    instance_type = "m5.xlarge"
    min_size      = "1"
    max_size      = "3"
    desired_size  = "1"
  }
  default_helm_config = {
    name              = "cd"
    repository        = join("/", [path.module, "charts"])
    chart             = "spinnaker"
    namespace         = "spinnaker"
    timeout           = "500"
    cleanup_on_fail   = true
    dependency_update = true
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
