### default values

### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  aws = {
    dns       = module.aws.partition.dns_suffix
    partition = module.aws.partition.partition
    region    = module.aws.region.name
    id        = module.aws.caller.account_id
  }
}
