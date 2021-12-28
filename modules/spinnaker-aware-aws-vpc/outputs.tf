# output variables 

output "vpc" {
  description = "The attributes of the secure vpc"
  value       = module.vpc.vpc
}

output "vpce" {
  description = "The attributes of VPC endpoints"
  value       = module.vpc.vpce
}

output "subnets" {
  description = "The map of subnet IDs"
  value       = module.vpc.subnets
}

output "route_tables" {
  description = "The map of route table IDs"
  value       = module.vpc.route_tables
}

output "vgw" {
  description = "The attributes of Virtual Private Gateway"
  value       = module.vpc.vgw
}
