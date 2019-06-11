# s3.tf
# simple storage service

### s3 admin
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
  policy = "${data.aws_iam_policy_document.s3admin.json}"
}

resource "aws_s3_bucket" "storage" {
  bucket = "${local.name}"
  tags   = "${var.tags}"

  lifecycle_rule {
    id      = "${local.name}"
    enabled = true

    tags = {
      "rule"      = "transit the current version object to IA after 90 days"
      "rule"      = "permanently delete the previous version object after 120 days"
      "autoclean" = "true"
    }

    transition {
      days          = 90
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

resource "aws_s3_bucket_object" "prefix_objects" {
  count   = "${length(var.s3_prefixies)}"
  bucket  = "${aws_s3_bucket.storage.id}"
  key     = "${var.s3_prefixies[count.index]}/"
  content = "${var.s3_prefixies[count.index]}/"
}
