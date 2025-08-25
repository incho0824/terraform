resource "google_service_account" "consumer_sa" {
  project    = var.project_id
  account_id = var.service_account_id
}
