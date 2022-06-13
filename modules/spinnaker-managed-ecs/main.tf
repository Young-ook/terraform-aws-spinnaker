## managed container cluster

## features
locals {
  node_groups_enabled = (var.node_groups != null ? ((length(var.node_groups) > 0) ? true : false) : false)
}

resource "aws_ecs_cluster" "cp" {
  name               = local.name
  tags               = merge(local.default-tags, var.tags)
  capacity_providers = [for ng in var.node_groups : ng.name if local.node_groups_enabled]

  dynamic "default_capacity_provider_strategy" {
    for_each = { for ng in var.node_groups : ng.name => ng if local.node_groups_enabled }
    content {
      capacity_provider = default_capacity_provider_strategy.key
    }
  }

  dynamic "setting" {
    for_each = {
      containerInsights = var.container_insights_enabled ? "enabled" : "disabled"
    }
    content {
      name  = setting.key
      value = setting.value
    }
  }

  depends_on = [
    aws_ecs_capacity_provider.ng,
  ]
}

## node groups (ng)
# security/policy
resource "aws_iam_role" "ng" {
  count = local.node_groups_enabled ? 1 : 0
  name  = format("%s-ng", local.name)
  tags  = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("ec2.%s", data.aws_partition.current.dns_suffix)]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_instance_profile" "ng" {
  count = local.node_groups_enabled ? 1 : 0
  name  = format("%s-ng", local.name)
  role  = aws_iam_role.ng.0.name
}

resource "aws_iam_role_policy_attachment" "ecs-ng" {
  count      = local.node_groups_enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role", data.aws_partition.current.partition)
  role       = aws_iam_role.ng.0.name
}

resource "aws_iam_role_policy_attachment" "ecr-read" {
  count      = local.node_groups_enabled ? 1 : 0
  policy_arn = format("arn:%s:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly", data.aws_partition.current.partition)
  role       = aws_iam_role.ng.0.name
}

# ecs-optimized linux
data "aws_ami" "ecs" {
  for_each    = { for ng in var.node_groups : ng.name => ng if local.node_groups_enabled }
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

data "template_cloudinit_config" "boot" {
  for_each      = { for ng in var.node_groups : ng.name => ng if local.node_groups_enabled }
  base64_encode = true
  gzip          = false

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOT
    #!/bin/bash -v
    echo ECS_CLUSTER=${local.name} >> /etc/ecs/ecs.config
    start ecs
    EOT
  }
}

resource "aws_launch_template" "ng" {
  for_each      = { for ng in var.node_groups : ng.name => ng if local.node_groups_enabled }
  name          = format("ecs-%s", uuid())
  tags          = merge(local.default-tags, var.tags)
  image_id      = data.aws_ami.ecs[each.key].id
  user_data     = data.template_cloudinit_config.boot[each.key].rendered
  instance_type = lookup(each.value, "instance_type", "t3.medium")

  iam_instance_profile {
    arn = aws_iam_instance_profile.ng.0.arn
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = lookup(each.value, "disk_size", "20")
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(local.default-tags, var.tags)
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_autoscaling_group" "ng" {
  for_each              = { for ng in var.node_groups : ng.name => ng if local.node_groups_enabled }
  name                  = format("ecs-%s", uuid())
  vpc_zone_identifier   = local.subnet_ids
  max_size              = lookup(each.value, "max_size", 3)
  min_size              = lookup(each.value, "min_size", 1)
  desired_capacity      = lookup(each.value, "desired_size", 1)
  force_delete          = true
  protect_from_scale_in = var.termination_protection
  termination_policies  = ["Default"]
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ng[each.key].id
        version            = aws_launch_template.ng[each.key].latest_version
      }

      dynamic "override" {
        for_each = lookup(each.value, "launch_override", [])
        content {
          instance_type     = lookup(override.value, "instance_type", null)
          weighted_capacity = lookup(override.value, "weighted_capacity", null)
        }
      }
    }

    dynamic "instances_distribution" {
      for_each = { for key, val in each.value : key => val if key == "instances_distribution" }
      content {
        on_demand_allocation_strategy            = lookup(instances_distribution.value, "on_demand_allocation_strategy", null)
        on_demand_base_capacity                  = lookup(instances_distribution.value, "on_demand_base_capacity", null)
        on_demand_percentage_above_base_capacity = lookup(instances_distribution.value, "on_demand_percentage_above_base_capacity", null)
        spot_allocation_strategy                 = lookup(instances_distribution.value, "spot_allocation_strategy", null)
        spot_instance_pools                      = lookup(instances_distribution.value, "spot_instance_pools", null)
        spot_max_price                           = lookup(instances_distribution.value, "spot_max_price", null)
      }
    }
  }

  dynamic "tag" {
    for_each = local.ecs-tag
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity, name]
  }

  depends_on = [
    aws_iam_role.ng,
    aws_iam_role_policy_attachment.ecs-ng,
    aws_iam_role_policy_attachment.ecr-read,
    aws_launch_template.ng,
  ]
}

## capacity providers (node groups)
resource "aws_ecs_capacity_provider" "ng" {
  for_each = { for ng in var.node_groups : ng.name => ng if local.node_groups_enabled }
  name     = each.key
  tags     = merge(local.default-tags, var.tags)

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ng[each.key].arn
    managed_termination_protection = var.termination_protection ? "ENABLED" : "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = lookup(each.value, "max_scaling_step_size", null)
      minimum_scaling_step_size = lookup(each.value, "min_scaling_step_size", null)
      status                    = "ENABLED"
      target_capacity           = lookup(each.value, "target_capacity", 100)
    }
  }
}
