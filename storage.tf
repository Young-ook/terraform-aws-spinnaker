
## s3 bucket for front50 storage

# security/role
resource "aws_iam_policy" "spin-s3admin" {
  name = format("%s-s3admin", local.name)
  policy = jsonencode({
    Statement = [
      {
        Action   = "s3:*"
        Effect   = "Allow"
        Resource = [format("arn:%s:s3:::%s/*", data.aws_partition.current.partition, local.name)]
      },
      {
        Action = [
          "s3:ListBucketByTags",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucketVersions",
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation",
        ]
        Effect   = "Allow"
        Resource = [format("arn:%s:s3:::%s", data.aws_partition.current.partition, local.name)]
      },
      {
        Action = [
          "s3:HeadBucket",
          "s3:ListAllMyBuckets",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "spin-artifact-writeonly" {
  name = format("%s-artifact-writeonly", local.name)
  policy = jsonencode({
    Statement = [{
      Action   = "s3:Put*"
      Effect   = "Allow"
      Resource = [format("arn:%s:s3:::%s/artifact/*", data.aws_partition.current.partition, local.name)]
    }]
    Version = "2012-10-17"
  })
}

resource "aws_s3_bucket" "storage" {
  bucket = local.name
  tags   = var.tags

  lifecycle_rule {
    id      = local.name
    enabled = true

    transition {
      days          = 180
      storage_class = "STANDARD_IA"
    }
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

locals {
  keys = ["front50", "kayenta", "halyard", "artifact"]
}

resource "aws_s3_bucket_object" "keys" {
  count                  = length(local.keys)
  bucket                 = aws_s3_bucket.storage.id
  key                    = format("%s/", element(local.keys, count.index))
  content                = format("%s/", element(local.keys, count.index))
  server_side_encryption = "AES256"
}
