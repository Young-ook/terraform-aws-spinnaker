## simple storage service

data "aws_partition" "current" {}

module "current" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

# security/policy
resource "aws_iam_policy" "read" {
  name        = format("%s-read", local.name)
  description = format("Allow to read objects and the S3 bucket")
  path        = "/"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "s3:HeadBucket",
          "s3:List*",
          "s3:Get*",
        ]
        Effect = "Allow"
        Resource = [
          format("arn:${data.aws_partition.current.partition}:s3:::%s/*", local.name),
          format("arn:${data.aws_partition.current.partition}:s3:::%s", local.name)
        ]
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "write" {
  name        = format("%s-write", local.name)
  description = format("Allow to write objects and the S3 bucket")
  path        = "/"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "s3:Put*",
          "s3:DeleteObject*",
        ]
        Effect = "Allow"
        Resource = [
          format("arn:${data.aws_partition.current.partition}:s3:::%s/*", local.name),
        ]
      },
      {
        Action = [
          "s3:HeadBucket",
        ]
        Effect = "Allow"
        Resource = [
          format("arn:${data.aws_partition.current.partition}:s3:::%s", local.name)
        ]
      }
    ]
    Version = "2012-10-17"
  })
}

# security/policy
resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = local.name
  tags          = merge(local.default-tags, var.tags)
  force_destroy = var.force_destroy
  acl           = var.canned_acl

  # logging policy
  dynamic "logging" {
    for_each = var.logging_rules
    content {
      target_bucket = lookup(logging.value, "target_bucket", local.name)
      target_prefix = lookup(logging.value, "target_prefix", "log")
    }
  }

  # object lifecycle policy
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      id      = lookup(lifecycle_rule.value, "id", null) == null ? local.name : lifecycle_rule.value["id"]
      enabled = lifecycle_rule.value["enabled"]
      tags    = lookup(lifecycle_rule.value, "tags", null)
      prefix  = lookup(lifecycle_rule.value, "prefix", null)

      dynamic "expiration" {
        for_each = {
          for key, val in lifecycle_rule.value : key => val if key == "expiration"
        }
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])
        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = {
          for key, val in lifecycle_rule.value : key => val if key == "noncurrent_version_expiration"
        }
        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])

        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }

  # server side encryption options
  dynamic "server_side_encryption_configuration" {
    for_each = var.server_side_encryption
    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = lookup(server_side_encryption_configuration.value, "sse_algorithm", null)
          kms_master_key_id = lookup(server_side_encryption_configuration.value, "kms_master_key_id", null)
        }
      }
    }
  }

  # enable object version control
  versioning {
    enabled = var.versioning
  }
}

locals {
  aws_region  = module.current.region.name
  bucket_name = aws_s3_bucket.bucket.id
}

# cleanup script
resource "local_file" "empty" {
  count      = var.force_destroy ? 1 : 0
  depends_on = [aws_s3_bucket.bucket]
  content = join("\n", [
    "#!/bin/sh",
    "aws s3api delete-objects \\",
    "  --region ${local.aws_region} --bucket ${local.bucket_name} \\",
    "  --delete \"$(aws s3api list-object-versions \\",
    "    --region ${local.aws_region} --bucket ${local.bucket_name} \\",
    "    --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \\",
    "    --output json)\"",
    "echo $?",
    "exit 0"
  ])
  filename        = "${path.module}/empty.sh"
  file_permission = "0700"
}

resource "null_resource" "empty" {
  count      = var.force_destroy ? 1 : 0
  depends_on = [local_file.empty]
  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/empty.sh"
  }
}
