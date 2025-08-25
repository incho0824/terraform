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
