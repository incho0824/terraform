resource "google_storage_bucket" "static" {
  project  = var.project_id
  name     = var.bucket_name
  location = var.location
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.static.name
  role   = "roles/storage.objectViewer"
  member = var.member
}
