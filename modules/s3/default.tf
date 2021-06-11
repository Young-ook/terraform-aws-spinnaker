### default values

locals {
  default_lifecycle_rules = [
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
}
