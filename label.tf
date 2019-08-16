# label.tf

resource "random_string" "this" {
  length  = 4
  upper   = false
  lower   = true
  number  = false
  special = false
}

### frigga naming rule
locals {
  name           = "${join("-", compact(list(var.name, var.stack, var.detail, local.slug)))}"
  slug           = "${var.slug == "" ? random_string.this.result : var.slug}"
  cluster_name   = "${local.name}"
  cluster_id     = "${local.name}"
  master_name    = "${join("-", compact(list(local.cluster_name, "eks")))}"
  node_pool_name = "${join("-", compact(list(local.cluster_name, "node-pool")))}"
}

### kubernetes tag
locals {
  k8s_tag_shared = "${map("kubernetes.io/cluster/${local.cluster_name}", "shared")}"
  k8s_tag_owned  = "${map("key", "kubernetes.io/cluster/${local.cluster_name}", "value", "owned", "propagate_at_launch", "true")}"
}
