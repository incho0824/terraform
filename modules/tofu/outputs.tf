output "user_service_url" {
  description = "URL of the user service"
  value       = google_cloud_run_v2_service.user_service.uri
}

output "docs_service_url" {
  description = "URL of the documentation service"
  value       = google_cloud_run_v2_service.docs_service.uri
}

output "cms_service_url" {
  description = "URL of the unified CMS service (frontend + backend)"
  value       = google_cloud_run_v2_service.cms_service.uri
}

output "restaurants_service_url" {
  description = "URL of the restaurants service"
  value       = google_cloud_run_v2_service.restaurants_service.uri
}

output "artifact_registry_repository" {
  description = "Artifact Registry repository for container images"
  value       = google_artifact_registry_repository.services.name
}

output "database_connection_name" {
  description = "Cloud SQL connection name for connecting via Cloud SQL Proxy"
  value       = google_sql_database_instance.postgres.connection_name
}

output "database_private_ip" {
  description = "Private IP address of the PostgreSQL database"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "database_name" {
  description = "Name of the main application database"
  value       = google_sql_database.foodmarks_db.name
}

output "database_user" {
  description = "Database username for application connections"
  value       = google_sql_user.db_user.name
}

output "database_secret_name" {
  description = "Secret Manager secret containing database connection details"
  value       = google_secret_manager_secret.db_connection_string.secret_id
}

output "cloudsql_service_account_email" {
  description = "Email of the Cloud SQL service account"
  value       = google_service_account.cloudsql_sa.email
}

output "restaurants_input_bucket" {
  description = "Cloud Storage bucket for restaurant input data"
  value       = google_storage_bucket.restaurants_input.name
}

output "restaurants_processed_bucket" {
  description = "Cloud Storage bucket for processed restaurant data"
  value       = google_storage_bucket.restaurants_processed.name
}

output "assets_bucket" {
  description = "Cloud Storage bucket for application assets"
  value       = google_storage_bucket.assets.name
}

output "public_url" {
  description = "Public base URL of the application"
  value       = "https://${local.full_prefix}.${var.lb_domain_name_suffix}"
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "database_password" {
  description = "Database password for application connections (sensitive)"
  value       = google_sql_user.db_user.password
  sensitive   = true
}

# Debug outputs for source file tracking
output "debug_cms_source_hash" {
  value = local.cms_source_hash
}

output "debug_api_source_hash" {
  value = local.api_source_hash
}

output "debug_cms_image_tag" {
  value = local.cms_image_tag
}

output "debug_api_image_tag" {
  value = local.api_image_tag
}

output "backup_schedules" {
  description = "Backup schedule information"
  value = {
    sql_automated_backup_time        = "03:00 UTC daily"
    sql_retention_days               = 30
    sql_point_in_time_recovery       = "7 days"
    firestore_daily_schedule         = "Daily (GCP managed)"
    firestore_daily_retention        = "14 days"
    firestore_weekly_schedule        = "Sunday (GCP managed)"
    firestore_weekly_retention       = "14 weeks"
    firestore_point_in_time_recovery = "7 days"
  }
}
