# output variables 

output "endpoint" {
  value       = local.enabled ? aws_rds_cluster.db.*.endpoint : []
  description = "The enpoint of aurora mysql cluster"
}
