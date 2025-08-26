resource "google_project_service" "run" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_cloud_run_service" "service" {
  project  = var.project_id
  name     = var.cloud_run_service_name
  location = var.region

  template {
    spec {
      containers {
        image = var.cloud_run_image
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "invoker" {
  project  = var.project_id
  location = google_cloud_run_service.service.location
  service  = google_cloud_run_service.service.name
  role     = "roles/run.invoker"
  member   = var.member
}

