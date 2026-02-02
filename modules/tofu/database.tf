# Enable Cloud SQL API
resource "google_project_service" "sql_api" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

# Cloud SQL PostgreSQL instance with PostGIS and pgvector support
resource "google_sql_database_instance" "postgres" {
  name             = "${local.full_prefix}-postgres"
  database_version = "POSTGRES_15"
  region           = var.region
  project          = var.project_id

  settings {
    tier = "db-f1-micro"

    availability_type = "ZONAL"

    disk_type             = "PD_SSD"
    disk_size             = 20
    disk_autoresize       = true
    disk_autoresize_limit = 100

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 30
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled    = var.sql_proxy
      private_network = data.terraform_remote_state.shared.outputs.shared_vpc_id
      ssl_mode        = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    }

    database_flags {
      name  = "max_connections"
      value = "100"
    }

    database_flags {
      name  = "shared_buffers"
      value = "32768"
    }

    database_flags {
      name  = "work_mem"
      value = "1024"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }
  }

  # Deletion protection enabled for production, disabled for dev (via is_production=false in tfvars)
  deletion_protection = var.is_production

  depends_on = [google_project_service.sql_api]
}

# Main application database
resource "google_sql_database" "foodmarks_db" {
  name     = "foodmarks"
  instance = google_sql_database_instance.postgres.name
  project  = var.project_id
}

# Generate a random password for the database user
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#%*+-=?"
}

# Create a secret to store the database password
resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "${local.full_prefix}-db-password"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.secret_manager_api]
}

# Store the generated password in Secret Manager
resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = random_password.db_password.result
}

# Database user
resource "google_sql_user" "db_user" {
  name     = "fm_admin"
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password.result
  project  = var.project_id

  # Ensure database is destroyed before user (user owns objects in the database)
  depends_on = [google_sql_database.foodmarks_db]
}

# Grant the main service account access to the DB password secret
resource "google_secret_manager_secret_iam_member" "db_password_secret_accessor" {
  project   = google_secret_manager_secret.db_password_secret.project
  secret_id = google_secret_manager_secret.db_password_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.firestore_sa.email}"
}

# Service account for Cloud SQL access
resource "google_service_account" "cloudsql_sa" {
  account_id   = "${local.full_prefix}-cloudsql-sa"
  display_name = "Cloud SQL Service Account for ${local.full_prefix}"
  project      = var.project_id
}

# Grant Cloud SQL Client role to service account
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudsql_sa.email}"
}

# Grant Cloud SQL Instance User role to service account
resource "google_project_iam_member" "cloudsql_instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${google_service_account.cloudsql_sa.email}"
}

# Store database credentials in Secret Manager
resource "google_project_service" "secretmanager_api" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_secret_manager_secret" "db_connection_string" {
  secret_id = "${local.full_prefix}-db-connection"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.secretmanager_api]
}

resource "google_secret_manager_secret_version" "db_connection_string" {
  secret = google_secret_manager_secret.db_connection_string.id
  secret_data = jsonencode({
    host            = google_sql_database_instance.postgres.private_ip_address
    port            = "5432"
    database        = google_sql_database.foodmarks_db.name
    username        = google_sql_user.db_user.name
    password        = google_sql_user.db_user.password
    connection_name = google_sql_database_instance.postgres.connection_name
  })
}

# Grant Cloud SQL permissions to Firestore service account (for dual database access)
resource "google_project_iam_member" "firestore_sa_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.firestore_sa.email}"
}

resource "google_project_iam_member" "firestore_sa_cloudsql_instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${google_service_account.firestore_sa.email}"
}

# Grant Secret Manager Secret Accessor role to Firestore service account
resource "google_secret_manager_secret_iam_member" "db_secret_accessor_firestore" {
  secret_id = google_secret_manager_secret.db_connection_string.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.firestore_sa.email}"
  project   = var.project_id
}

# Keep Cloud SQL service account for potential future use
resource "google_secret_manager_secret_iam_member" "db_secret_accessor_cloudsql" {
  secret_id = google_secret_manager_secret.db_connection_string.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloudsql_sa.email}"
  project   = var.project_id
}

# Firestore permissions for the service account
resource "google_project_iam_member" "firestore_datastore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.firestore_sa.email}"
}

resource "google_project_iam_member" "firestore_database_viewer" {
  project = var.project_id
  role    = "roles/firebase.viewer"
  member  = "serviceAccount:${google_service_account.firestore_sa.email}"
}
