resource "google_project_service" "run" {
  project = var.project_id
  service = "run.googleapis.com"
}
