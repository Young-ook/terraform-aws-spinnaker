aws_region    = "ap-northeast-2"
name          = "s3"
stack         = "dev"
detail        = "tc2"
force_destroy = true
versioning    = true
lifecycle_rules = [
  {
    "enabled" : "true",
    "expiration" : {
      "days" : "365"
    },
    "id" : null,
    "prefix" : null,
    "noncurrent_version_expiration" : {
      "days" : "120"
    },
    "noncurrent_version_transition" : [],
    "tags" : {},
    "transition" : [
      {
        "days" : "180",
        "storage_class" : "STANDARD_IA"
      }
    ]
  }
]
tags = {
  env             = "dev"
  test            = "tc2"
  versioning      = "true"
  force-destroy   = "true"
  lifecycle-rules = "enabled"
}
