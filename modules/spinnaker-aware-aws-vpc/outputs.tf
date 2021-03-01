# output variables 

output "vpc" {
  description = "The attributes of the secure vpc"
  value       = aws_vpc.vpc
}

output "vpce" {
  description = "The attributes of VPC endpoints"
  value       = aws_vpc_endpoint.vpce
}

locals {
  isolated_subnets = { for key, val in aws_subnet.isolated : key => val.id }
  private_subnets  = { for key, val in aws_subnet.private : key => val.id }
  public_subnets   = { for key, val in aws_subnet.public : key => val.id }
}

output "subnets" {
  description = "The map of subnet IDs"
  value = zipmap(
    ["isolated", "private", "public"],
    [local.isolated_subnets, local.private_subnets, local.public_subnets]
  )
}
