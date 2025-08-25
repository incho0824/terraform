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
