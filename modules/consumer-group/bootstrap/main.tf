# Enable Artifact Registry API
resource "google_project_service" "artifact_registry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

# Service account for consumer applications
resource "google_service_account" "consumer_sa" {
  project    = var.project_id
  account_id = var.service_account_id
}

# State storage bucket and access
resource "google_storage_bucket" "state" {
  name                        = var.state_bucket_name
  location                    = var.location
  project                     = var.project_id
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_iam_member" "state_writer" {
  bucket = google_storage_bucket.state.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.consumer_sa.email}"
}

# Artifact Registry repository and access
resource "google_artifact_registry_repository" "consumer_repo" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  format        = var.repository_format
}

resource "google_artifact_registry_repository_iam_member" "consumer_sa_writer" {
  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.consumer_repo.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.consumer_sa.email}"
}
