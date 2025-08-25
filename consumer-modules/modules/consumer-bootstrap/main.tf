resource "google_storage_bucket" "state" {
  name = var.state_bucket_name
  location = var.location
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_artifact_registry_repository" "consumer_repo" {
  repository_id = var.repository_id
  format = var.repository_format
}

resource "google_service_account" "consumer_sa" {
  account_id = var.service_account_id
}

resource "google_storage_bucket_iam_member" "state_writer" {
  bucket = google_storage_bucket.state.name
  role = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.consumer_sa.email}"
}

resource "google_artifact_registry_repository_iam_member" "consumer_sa_writer" {
  repository = google_artifact_registry_repository.consumer_repo.repository_id
  role = "roles/artifactregistry.writer"
  member = "serviceAccount:${google_service_account.consumer_sa.email}"
}