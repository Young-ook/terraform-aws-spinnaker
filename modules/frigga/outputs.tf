output "name" {
  value       = local.name
  description = "The generated name for your AWS resource"
}

output "nametag" {
  value       = local.name-tag
  description = "The map of name-tag to attach to your AWS resource"
}
