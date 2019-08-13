
## s3 bucket for front50 storage

# security/role
data "aws_iam_policy_document" "s3admin" {
  statement {
    effect    = "Allow"
    resources = ["arn:aws:s3:::${local.name}/*"]
    actions   = ["s3:*"]
  }

  statement {
    effect    = "Allow"
    resources = ["arn:aws:s3:::${local.name}"]

    actions = [
      "s3:ListBucketByTags",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:ListBucket",
      "s3:GetBucketVersioning",
      "s3:GetBucketLocation",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:HeadBucket",
      "s3:ListAllMyBuckets",
    ]
  }
}

resource "aws_iam_policy" "s3admin" {
  name   = "${local.name}-s3admin"
  policy = data.aws_iam_policy_document.s3admin.json
}

resource "aws_s3_bucket" "storage" {
  bucket = local.name
  tags   = var.tags

  lifecycle_rule {
    id      = local.name
    enabled = true

    tags = {
      "rule"      = "transit the current version object to IA after 180 days"
      "rule"      = "permanently delete the previous version object after 120 days"
      "autoclean" = "true"
    }

    transition {
      days          = 180
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      days = 120
    }
  }

  versioning {
    enabled = true
  }
}

locals {
  keys = ["front50", "kayenta", "halyard"]
}

resource "aws_s3_bucket_object" "keys" {
  count                  = length(local.keys)
  bucket                 = aws_s3_bucket.storage.id
  key                    = format("%s/", element(local.keys, count.index))
  content                = format("%s/", element(local.keys, count.index))
  server_side_encryption = "AES256"
}
