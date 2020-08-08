
output "name" {
  description = "The service account name of spinnaker managed role"
  value       = google_service_account.spinnaker-managed.name
}

output "email" {
  description = "The service account email address of spinnaker managed role"
  value       = google_service_account.spinnaker-managed.email
}

output "id" {
  description = "The service account resource identity of spinnaker managed role"
  value       = google_service_account.spinnaker-managed.unique_id
}
