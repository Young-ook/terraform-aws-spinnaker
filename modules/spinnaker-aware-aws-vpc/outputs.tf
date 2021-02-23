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
  private_subnets = { for key, val in aws_subnet.private : key => val.id }
}

output "private_subnets" {
  description = "The list of private subnet IDs"
  value       = local.private_subnets
}
