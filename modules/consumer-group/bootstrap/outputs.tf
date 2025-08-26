output "state_bucket" {
  value = google_storage_bucket.state.name
}

output "artifact_registry_repository" {
  value = google_artifact_registry_repository.consumer_repo.id
}

output "service_account_email" {
  value = google_service_account.consumer_sa.email
}
