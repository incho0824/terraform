terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 7.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

data "terraform_remote_state" "shared" {
  backend = "gcs"

  config = {
    bucket = var.cloud_project == "TCCC" ? "fm30-shared-foodmarks3-tfstate" : "shared-foodmarks3-tfstate"
    prefix = "firebase/state"
  }
}

# External data sources to compute source hashes via shell commands
# This fixes the issue where Terraform's fileset() doesn't match paths with special characters like [locale] and (edit)
data "external" "cms_source_hash" {
  program = ["bash", "-c", <<-EOT
    cd "${path.module}/.."
    hash=$(find cms -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.mjs" -o -name "*.cjs" -o -name "*.json" -o -name "*.html" -o -name "*.css" \) \
      ! -path "*/node_modules/*" ! -path "*/dist/*" ! -path "*/build/*" ! -path "*/.next/*" ! -path "*/out/*" \
      -exec sha256sum {} \; 2>/dev/null | sort | sha256sum | cut -c1-64)
    repo_hash=$(find repository -type f \( -name "*.ts" -o -name "*.js" -o -name "*.json" \) \
      ! -path "*/node_modules/*" ! -path "*/dist/*" ! -path "*/build/*" \
      -exec sha256sum {} \; 2>/dev/null | sort | sha256sum | cut -c1-64)
    dockerfile_hash=$(sha256sum cms/Dockerfile 2>/dev/null | cut -c1-64 || echo "0")
    combined=$(echo "$hash$repo_hash$dockerfile_hash" | sha256sum | cut -c1-64)
    echo "{\"hash\": \"$combined\"}"
  EOT
  ]
}

data "external" "api_source_hash" {
  program = ["bash", "-c", <<-EOT
    cd "${path.module}/.."
    hash=$(find api -type f \( -name "*.ts" -o -name "*.js" -o -name "*.json" -o -name "*.py" -o -name "*.txt" \) \
      ! -path "*/node_modules/*" ! -path "*/dist/*" ! -path "*/build/*" ! -path "*/__pycache__/*" ! -path "*/venv/*" \
      -exec sha256sum {} \; 2>/dev/null | sort | sha256sum | cut -c1-64)
    dockerfile_hash=$(find api -name "Dockerfile" -exec sha256sum {} \; 2>/dev/null | sort | sha256sum | cut -c1-64)
    combined=$(echo "$hash$dockerfile_hash" | sha256sum | cut -c1-64)
    echo "{\"hash\": \"$combined\"}"
  EOT
  ]
}

data "external" "bootstrap_source_hash" {
  program = ["bash", "-c", <<-EOT
    cd "${path.module}/.."
    hash=$(cat Dockerfile.bootstrap drizzle.config.ts package.json package-lock.json 2>/dev/null | sha256sum | cut -c1-64)
    cli_hash=$(find cli -type f \( -name "*.ts" -o -name "*.sql" -o -name "*.json" -o -name "*.jsonc" -o -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) \
      -exec sha256sum {} \; 2>/dev/null | sort | sha256sum | cut -c1-64)
    drizzle_hash=$(find drizzle -type f \( -name "*.ts" -o -name "*.js" -o -name "*.sql" -o -name "*.json" \) \
      -exec sha256sum {} \; 2>/dev/null | sort | sha256sum | cut -c1-64)
    combined=$(echo "$hash$cli_hash$drizzle_hash" | sha256sum | cut -c1-64)
    echo "{\"hash\": \"$combined\"}"
  EOT
  ]
}

locals {
  # Source hashes from external data sources
  # Uses find command which properly handles paths with special characters like [locale] and (edit)
  cms_source_hash       = data.external.cms_source_hash.result.hash
  api_source_hash       = data.external.api_source_hash.result.hash
  bootstrap_source_hash = data.external.bootstrap_source_hash.result.hash

  # Combined hash for when gateway changes (affects all services)
  all_source_hash = sha256(join("", [
    local.cms_source_hash,
    local.api_source_hash
  ]))

  # Service-specific image tags
  cms_image_tag       = substr(local.cms_source_hash, 0, 8)
  api_image_tag       = substr(local.api_source_hash, 0, 8)
  bootstrap_image_tag = substr(local.bootstrap_source_hash, 0, 8)
  all_image_tag       = substr(local.all_source_hash, 0, 8)

  developer_prefix   = var.developer_prefix
  environment_prefix = var.environment_prefix

  # Add cloud project prefix for TCCC to avoid naming conflicts
  cloud_project_prefix = var.cloud_project == "TCCC" ? "fm30-" : ""

  # Build full_prefix conditionally - omit dash when developer_prefix is empty
  # For TCCC, prepend fm30- to avoid naming conflicts with MVP resources
  base_prefix = var.developer_prefix != "" ? "${local.environment_prefix}-${local.developer_prefix}" : local.environment_prefix
  full_prefix = "${local.cloud_project_prefix}${local.base_prefix}"

  # Suffix for resources with GCP deletion cooldown (Cloud Tasks queues = 3 days)
  # Append only when resource_suffix is set
  queue_suffix = var.resource_suffix != "" ? "-${var.resource_suffix}" : ""

  effective_identity_api_key   = data.terraform_remote_state.shared.outputs.firebase_browser_api_key
  effective_recaptcha_site_key = data.terraform_remote_state.shared.outputs.recaptcha_site_key

  db_secret_version = google_secret_manager_secret_version.db_connection_string.name
}

# Enable required APIs
resource "google_project_service" "cloud_run_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloud_build_api" {
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifact_registry_api" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "secret_manager_api" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloud_tasks_api" {
  service            = "cloudtasks.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage_api" {
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

# Identity Platform API Key Secret
resource "google_secret_manager_secret" "identity_platform_api_key" {
  secret_id = "${local.full_prefix}-identity-platform-api-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secret_manager_api]
}

# Store the Identity Platform API key value
resource "google_secret_manager_secret_version" "identity_platform_api_key_version" {
  secret      = google_secret_manager_secret.identity_platform_api_key.id
  secret_data = local.effective_identity_api_key
}

# Grant CMS service account access to the Identity Platform API key secret
resource "google_secret_manager_secret_iam_member" "cms_secret_access" {
  secret_id = google_secret_manager_secret.identity_platform_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.firestore_sa.email}"
}

# Google Maps API Key Secret
resource "google_secret_manager_secret" "google_maps_api_key" {
  secret_id = "${local.full_prefix}-google-maps-api-key"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secret_manager_api]
}

# Store the Google Maps API key value
resource "google_secret_manager_secret_version" "google_maps_api_key_version" {
  secret      = google_secret_manager_secret.google_maps_api_key.id
  secret_data = var.google_maps_api_key
}

# Grant restaurant service account access to the Google Maps API key secret
resource "google_secret_manager_secret_iam_member" "restaurant_sa_maps_access" {
  secret_id = google_secret_manager_secret.google_maps_api_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.restaurant_sa.email}"
}

# Data Retrieval User Secret
resource "google_secret_manager_secret" "data_retrieval_user" {
  secret_id = "${local.full_prefix}-data-retrieval-user"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secret_manager_api]
}

# Store the data retrieval user value
resource "google_secret_manager_secret_version" "data_retrieval_user_version" {
  secret      = google_secret_manager_secret.data_retrieval_user.id
  secret_data = var.data_retrieval_user
}

# Data Retrieval Password Secret
resource "google_secret_manager_secret" "data_retrieval_password" {
  secret_id = "${local.full_prefix}-data-retrieval-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.secret_manager_api]
}

# Store the data retrieval password value
resource "google_secret_manager_secret_version" "data_retrieval_password_version" {
  secret      = google_secret_manager_secret.data_retrieval_password.id
  secret_data = var.data_retrieval_password
}

# Grant restaurant service account access to data retrieval credentials
resource "google_secret_manager_secret_iam_member" "restaurant_sa_data_retrieval_user_access" {
  secret_id = google_secret_manager_secret.data_retrieval_user.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.restaurant_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "restaurant_sa_data_retrieval_password_access" {
  secret_id = google_secret_manager_secret.data_retrieval_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.restaurant_sa.email}"
}

# POE Configuration Secret
resource "google_secret_manager_secret" "poe_config" {
  secret_id = "${local.full_prefix}-poe-config"

  replication {
    auto {}
  }
}

# Store the POE configuration value
resource "google_secret_manager_secret_version" "poe_config_version" {
  secret      = google_secret_manager_secret.poe_config.id
  secret_data = var.poe_config
}

# Grant checkins service account access to the POE config secret
resource "google_secret_manager_secret_iam_member" "firestore_sa_poe_access" {
  secret_id = google_secret_manager_secret.poe_config.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.firestore_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "firestore_sa_db_secret_accessor" {
  secret_id = google_secret_manager_secret.db_connection_string.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.firestore_sa.email}"
}

resource "google_artifact_registry_repository" "services" {
  provider      = google-beta
  location      = var.region
  repository_id = "${local.full_prefix}-services"
  description   = "Repository for container images"
  format        = "DOCKER"
}

# Cloud Tasks queue for restaurant processing (project-wide, shared across environments)
# NOTE: Cloud Tasks queues have 3-day deletion cooldown - use resource_suffix to avoid conflicts
resource "google_cloud_tasks_queue" "restaurant_processing" {
  name     = "${local.full_prefix}-restaurant-processor-queue${local.queue_suffix}"
  location = var.region
  project  = var.project_id

  rate_limits {
    max_concurrent_dispatches = 5
    max_dispatches_per_second = 1
  }

  retry_config {
    max_attempts       = 3
    max_retry_duration = "300s"
    min_backoff        = "10s"
    max_backoff        = "60s"
  }

  depends_on = [google_project_service.cloud_tasks_api]
}

# User Service (Cloud Run)
resource "google_cloud_run_v2_service" "user_service" {
  name                 = "${local.full_prefix}-${var.service_name}-users"
  location             = var.region
  project              = var.project_id
  deletion_protection  = false # recoverable
  invoker_iam_disabled = true

  template {
    service_account = google_service_account.firestore_sa.email

    # Force service restart when DB secret version changes
    annotations = {
      "db-secret-version" = local.db_secret_version
    }

    vpc_access {
      network_interfaces {
        network    = data.terraform_remote_state.shared.outputs.shared_vpc_id
        subnetwork = data.terraform_remote_state.shared.outputs.shared_app_subnet_id
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.services.name}/user:${local.api_image_tag}"

      env {
        name  = "DB_PASSWORD_SECRET_NAME"
        value = google_secret_manager_secret.db_password_secret.secret_id
      }

      ports {
        container_port = 8080
      }

      env {
        name  = "PROJECT_ROOT"
        value = "/app"
      }
      env {
        name  = "FULL_PREFIX"
        value = local.full_prefix
      }
      env {
        name  = "DB_SECRET_NAME"
        value = google_secret_manager_secret.db_connection_string.secret_id
      }
      env {
        name  = "CLOUD_SQL_CONNECTION_NAME"
        value = google_sql_database_instance.postgres.connection_name
      }
      env {
        name  = "POE_SECRET_NAME"
        value = google_secret_manager_secret.poe_config.secret_id
      }
      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }
      env {
        name  = "POE_REQUEST_PROCESSOR_SERVICE_URL"
        value = google_cloud_run_v2_service.poe_service.uri
      }
      env {
        name  = "SERVICE_ACCOUNT_EMAIL"
        value = google_service_account.user_sa.email
      }
      env {
        name  = "CLOUD_TASKS_LOCATION"
        value = var.region
      }
      env {
        name  = "POE_REQUEST_QUEUE"
        value = google_cloud_tasks_queue.poe_request_queue.name
      }
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
        # Required by the user controller to be able to call PoE service after the response has been sent
        cpu_idle = false
      }
    }

    scaling {
      max_instance_count = 10
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  depends_on = [google_project_service.cloud_run_api, null_resource.build_and_push_api]
}

# Documentation Service (Cloud Run)
resource "google_cloud_run_v2_service" "docs_service" {
  name                 = "${local.full_prefix}-${var.service_name}-docs"
  location             = var.region
  project              = var.project_id
  deletion_protection  = false # recoverable
  invoker_iam_disabled = true

  template {

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.services.name}/docs:${local.api_image_tag}"

      ports {
        container_port = 8080
      }

      env {
        name  = "PROJECT_ROOT"
        value = "/app"
      }
      env {
        name  = "USER_SERVICE_URL"
        value = google_cloud_run_v2_service.user_service.uri
      }

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }

    scaling {
      max_instance_count = 5
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  depends_on = [google_project_service.cloud_run_api, null_resource.build_and_push_api]
}

# Firestore Service Account
resource "google_service_account" "firestore_sa" {
  account_id   = "${local.full_prefix}-firestore-sa"
  display_name = "Firestore Service Account for ${local.full_prefix}"
  project      = var.project_id
}

resource "google_project_iam_member" "firestore_sa_identity_platform_admin" {
  project = var.project_id
  role    = "roles/identityplatform.admin"
  member  = "serviceAccount:${google_service_account.firestore_sa.email}"
}

resource "google_project_iam_member" "firestore_sa_token_creator" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.firestore_sa.email}"
}

resource "google_project_iam_member" "firestore_sa_cloud_tasks_enqueuer" {
  project = var.project_id
  role    = "roles/cloudtasks.enqueuer"
  member  = "serviceAccount:${google_service_account.firestore_sa.email}"
}

# Check-ins Service (Cloud Run)
resource "google_cloud_run_v2_service" "checkins_service" {
  name                 = "${local.full_prefix}-${var.service_name}-checkins"
  location             = var.region
  project              = var.project_id
  deletion_protection  = false # recoverable
  invoker_iam_disabled = true

  template {
    service_account = google_service_account.firestore_sa.email

    # Force service restart when DB secret version changes
    annotations = {
      "db-secret-version" = local.db_secret_version
    }

    vpc_access {
      network_interfaces {
        network    = data.terraform_remote_state.shared.outputs.shared_vpc_id
        subnetwork = data.terraform_remote_state.shared.outputs.shared_app_subnet_id
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.services.name}/checkins:${local.api_image_tag}"

      ports {
        container_port = 8080
      }

      env {
        name  = "PROJECT_ROOT"
        value = "/app"
      }
      env {
        name  = "FULL_PREFIX"
        value = local.full_prefix
      }
      env {
        name  = "DB_SECRET_NAME"
        value = google_secret_manager_secret.db_connection_string.secret_id
      }
      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }
      env {
        name  = "POE_SECRET_NAME"
        value = google_secret_manager_secret.poe_config.secret_id
      }
      env {
        name  = "POE_REQUEST_PROCESSOR_SERVICE_URL"
        value = google_cloud_run_v2_service.poe_service.uri
      }
      env {
        name  = "SERVICE_ACCOUNT_EMAIL"
        value = google_service_account.user_sa.email
      }
      env {
        name  = "CLOUD_TASKS_LOCATION"
        value = var.region
      }
      env {
        name  = "POE_REQUEST_QUEUE"
        value = google_cloud_tasks_queue.poe_request_queue.name
      }
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
        # Required by the rewards controller to be able to call PoE service after the response has been sent
        cpu_idle = false
      }
    }

    scaling {
      max_instance_count = 10
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  depends_on = [google_project_service.cloud_run_api, null_resource.build_and_push_api]
}

# PoE Service (Cloud Run)
resource "google_cloud_run_v2_service" "poe_service" {
  name                = "${local.full_prefix}-${var.service_name}-poe"
  location            = var.region
  project             = var.project_id
  deletion_protection = false # recoverable

  template {
    service_account = google_service_account.firestore_sa.email

    vpc_access {
      network_interfaces {
        network    = data.terraform_remote_state.shared.outputs.shared_vpc_id
        subnetwork = data.terraform_remote_state.shared.outputs.shared_app_subnet_id
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.services.name}/poe:${local.api_image_tag}"

      ports {
        container_port = 8080
      }

      env {
        name  = "PROJECT_ROOT"
        value = "/app"
      }
      env {
        name  = "FULL_PREFIX"
        value = local.full_prefix
      }
      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }
      env {
        name  = "POE_SECRET_NAME"
        value = google_secret_manager_secret.poe_config.secret_id
      }
      env {
        name  = "SERVICE_ACCOUNT_EMAIL"
        value = google_service_account.user_sa.email
      }
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }

    scaling {
      max_instance_count = 5
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  depends_on = [google_project_service.cloud_run_api, null_resource.build_and_push_api]
}

# Restaurants Service (Cloud Run)
resource "google_cloud_run_v2_service" "restaurants_service" {
  name                 = "${local.full_prefix}-${var.service_name}-restaurants"
  location             = var.region
  project              = var.project_id
  deletion_protection  = false # recoverable
  invoker_iam_disabled = true

  template {
    service_account = google_service_account.firestore_sa.email

    # Force service restart when DB secret version changes
    annotations = {
      "db-secret-version" = local.db_secret_version
    }

    vpc_access {
      network_interfaces {
        network    = data.terraform_remote_state.shared.outputs.shared_vpc_id
        subnetwork = data.terraform_remote_state.shared.outputs.shared_app_subnet_id
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.services.name}/restaurants:${local.api_image_tag}"

      ports {
        container_port = 8080
      }

      env {
        name  = "DB_SECRET_NAME"
        value = google_secret_manager_secret.db_connection_string.secret_id
      }
      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }
      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "PUBLIC_URL"
        value = "https://${local.full_prefix}.${var.lb_domain_name_suffix}"
      }

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }

    scaling {
      max_instance_count = 10
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  depends_on = [google_project_service.cloud_run_api, null_resource.build_and_push_api]
}

# Cloud Run services are now configured with INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER
# No public IAM policies needed as services are not publicly accessible

###############################
# CMS Service (Cloud Run) - Unified Frontend + Backend
###############################
resource "google_cloud_run_v2_service" "cms_service" {
  name                 = "${local.full_prefix}-${var.service_name}-cms"
  location             = var.region
  project              = var.project_id
  deletion_protection  = false # recoverable
  invoker_iam_disabled = true

  template {
    service_account = google_service_account.firestore_sa.email

    # Force service restart when DB secret version changes
    annotations = {
      "db-secret-version" = local.db_secret_version
    }

    vpc_access {
      network_interfaces {
        network    = data.terraform_remote_state.shared.outputs.shared_vpc_id
        subnetwork = data.terraform_remote_state.shared.outputs.shared_app_subnet_id
      }
      egress = "PRIVATE_RANGES_ONLY"
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.services.name}/cms:${local.cms_image_tag}"

      ports {
        container_port = 8080
      }

      env {
        name  = "PROJECT_ROOT"
        value = "/app"
      }
      env {
        name  = "FULL_PREFIX"
        value = local.full_prefix
      }
      env {
        name  = "DB_SECRET_NAME"
        value = google_secret_manager_secret.db_connection_string.secret_id
      }
      env {
        name  = "CLOUD_SQL_CONNECTION_NAME"
        value = google_sql_database_instance.postgres.connection_name
      }
      env {
        name  = "NEXT_PUBLIC_RECAPTCHA_SITE_KEY"
        value = local.effective_recaptcha_site_key
      }
      env {
        name  = "IDENTITY_API_SECRET_NAME"
        value = google_secret_manager_secret.identity_platform_api_key.secret_id
      }
      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }
      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "ASSETS_BUCKET"
        value = google_storage_bucket.assets.name
      }
      env {
        name  = "PUBLIC_URL"
        value = "https://${local.full_prefix}.${var.lb_domain_name_suffix}"
      }
      resources {
        limits = {
          cpu    = "1000m"
          memory = "1Gi"
        }
      }
    }

    scaling {
      max_instance_count = 10
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  depends_on = [google_project_service.cloud_run_api, null_resource.build_and_push_cms]
}

###############################
# Bootstrap Service Account
###############################
resource "google_service_account" "bootstrap_sa" {
  account_id   = "${local.full_prefix}-bootstrap-sa"
  display_name = "Bootstrap Service Account for ${local.full_prefix}"
  project      = var.project_id
}

resource "google_project_iam_member" "bootstrap_sa_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.bootstrap_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "bootstrap_sa_db_secret_accessor" {
  secret_id = google_secret_manager_secret.db_connection_string.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.bootstrap_sa.email}"
}

# Storage access for bootstrap (seed images upload + bucket verification)
resource "google_storage_bucket_iam_member" "bootstrap_sa_assets_writer" {
  bucket = google_storage_bucket.assets.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.bootstrap_sa.email}"
}

###############################
# Bootstrap Job (Cloud Run)
# Runs: db init + migrate + seed + assets upload
###############################
resource "google_cloud_run_v2_job" "bootstrap" {
  name                = "${local.full_prefix}-${var.service_name}-bootstrap"
  location            = var.region
  project             = var.project_id
  deletion_protection = false # recoverable

  template {
    template {
      service_account = google_service_account.bootstrap_sa.email

      vpc_access {
        network_interfaces {
          network    = data.terraform_remote_state.shared.outputs.shared_vpc_id
          subnetwork = data.terraform_remote_state.shared.outputs.shared_app_subnet_id
        }
        egress = "PRIVATE_RANGES_ONLY"
      }

      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.services.name}/bootstrap:${local.bootstrap_image_tag}"

        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }

        env {
          name  = "DB_SECRET_NAME"
          value = google_secret_manager_secret.db_connection_string.secret_id
        }

        env {
          name  = "ASSETS_BUCKET"
          value = google_storage_bucket.assets.name
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
        }
      }
    }

    task_count  = 1
    parallelism = 1
  }

  depends_on = [google_project_service.cloud_run_api, null_resource.build_and_push_bootstrap]
}

###############################
# Restaurant Scheduler Service (Cloud Run)
###############################
resource "google_cloud_run_v2_service" "restaurant_scheduler_service" {
  name                 = "${local.full_prefix}-${var.service_name}-processing-scheduler"
  location             = var.region
  project              = var.project_id
  deletion_protection  = false # recoverable
  invoker_iam_disabled = true

  template {
    service_account = google_service_account.restaurant_sa.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.services.name}/processing-scheduler:${local.api_image_tag}"

      ports {
        container_port = 8080
      }

      env {
        name  = "PROJECT_ROOT"
        value = "/app"
      }
      env {
        name  = "FULL_PREFIX"
        value = local.full_prefix
      }
      env {
        name  = "SERVICE_ACCOUNT_EMAIL"
        value = google_service_account.restaurant_sa.email
      }
      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }
      env {
        name  = "CLOUD_TASKS_LOCATION"
        value = var.region
      }
      env {
        name  = "CLOUD_TASKS_QUEUE"
        value = google_cloud_tasks_queue.restaurant_processing.name
      }
      env {
        name  = "RESTAURANT_PROCESSOR_URL"
        value = google_cloud_run_v2_service.restaurant_processor_service.uri
      }
      env {
        name  = "RESTAURANTS_BUCKET"
        value = google_storage_bucket.restaurants_input.name
      }
      env {
        name  = "DATA_RETRIEVAL_USER_SECRET"
        value = google_secret_manager_secret.data_retrieval_user.secret_id
      }
      env {
        name  = "DATA_RETRIEVAL_PASSWORD_SECRET"
        value = google_secret_manager_secret.data_retrieval_password.secret_id
      }

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }

    scaling {
      max_instance_count = 5
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  depends_on = [google_project_service.cloud_run_api, null_resource.build_and_push_api]
}

###############################
# Restaurant Processor Service (Cloud Run)
###############################
resource "google_cloud_run_v2_service" "restaurant_processor_service" {
  name                 = "${local.full_prefix}-${var.service_name}-restaurant-processor"
  location             = var.region
  project              = var.project_id
  deletion_protection  = false # recoverable
  invoker_iam_disabled = true

  template {
    service_account = google_service_account.restaurant_sa.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.services.name}/restaurant-processor:${local.api_image_tag}"

      ports {
        container_port = 8080
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }
      env {
        name  = "VERTEX_AI_LOCATION"
        value = var.region
      }
      env {
        name  = "PROCESSED_RESTAURANTS_BUCKET"
        value = google_storage_bucket.restaurants_processed.name
      }
      env {
        name  = "GOOGLE_MAPS_API_KEY"
        value = var.google_maps_api_key
      }
      env {
        name  = "GOOGLE_CUSTOM_SEARCH_API_KEY"
        value = var.google_custom_search_api_key
      }
      env {
        name  = "GOOGLE_CUSTOM_SEARCH_ENGINE_ID"
        value = var.google_custom_search_engine_id
      }
      env {
        name  = "LOG_LEVEL"
        value = "INFO"
      }
      env {
        name  = "FULL_PREFIX"
        value = local.full_prefix
      }

      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
    }

    scaling {
      max_instance_count = 10
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  depends_on = [google_project_service.cloud_run_api, null_resource.build_and_push_api]
}

# Restaurant Services Service Account
resource "google_service_account" "restaurant_sa" {
  account_id   = "${local.full_prefix}-restaurant-sa"
  display_name = "Restaurant Services Service Account for ${local.full_prefix}"
  project      = var.project_id
}

# Grant restaurant service account access to Cloud Storage buckets
resource "google_storage_bucket_iam_member" "restaurant_sa_input_bucket_access" {
  bucket = google_storage_bucket.restaurants_input.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.restaurant_sa.email}"
}

resource "google_storage_bucket_iam_member" "restaurant_sa_processed_bucket_access" {
  bucket = google_storage_bucket.restaurants_processed.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.restaurant_sa.email}"
}

# Cloud Build dedicated service account
resource "google_service_account" "cloud_build" {
  account_id   = "${local.full_prefix}-cloud-build"
  display_name = "Cloud Build Service Account for ${local.full_prefix}"
  project      = var.project_id
}

# Grant Cloud Build service account access to Storage and Artifact Registry
resource "google_project_iam_member" "cloud_build_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

resource "google_project_iam_member" "cloud_build_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

# Allow Cloud Build service account to run builds (service account user)
resource "google_project_iam_member" "cloud_build_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloud_build.email}"
}

# Grant CMS service account access to assets bucket
resource "google_storage_bucket_iam_member" "cms_sa_assets_bucket_access" {
  bucket = google_storage_bucket.assets.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.firestore_sa.email}"
}

# Grant restaurant service account access to Cloud Tasks
resource "google_project_iam_member" "restaurant_sa_cloud_tasks_enqueuer" {
  project = var.project_id
  role    = "roles/cloudtasks.enqueuer"
  member  = "serviceAccount:${google_service_account.restaurant_sa.email}"
}

# Grant restaurant service account permission to act as itself (for Cloud Tasks authentication)
resource "google_service_account_iam_member" "restaurant_sa_act_as" {
  service_account_id = google_service_account.restaurant_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.restaurant_sa.email}"
}

# Grant restaurant service account access to AI Platform for Gemini API
resource "google_project_iam_member" "restaurant_sa_aiplatform_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.restaurant_sa.email}"
}

# Grant restaurant service account access to Firestore for run tracking
resource "google_project_iam_member" "restaurant_sa_datastore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.restaurant_sa.email}"
}

# PromoPlus API Configuration Secret
resource "google_secret_manager_secret" "promoplus_api_config" {
  secret_id = "${local.full_prefix}-promoplus-api-config"

  replication {
    auto {}
  }
}

# Store the PromoPlus API configuration value
resource "google_secret_manager_secret_version" "promoplus_api_config_version" {
  secret = google_secret_manager_secret.promoplus_api_config.id
  secret_data = jsonencode({
    apiUrl    = var.promoplus_api_url
    apiKey    = var.promoplus_api_key
    configId  = var.promoplus_config_id,
    stsKeyId  = var.promoplus_sts_key_id,
    stsSecret = var.promoplus_sts_secret,
    stsRegion = var.promoplus_sts_region
  })
}

# Grant CMS service account access to the PromoPlus API configuration secret
resource "google_secret_manager_secret_iam_member" "cms_promoplus_secret_access" {
  secret_id = google_secret_manager_secret.promoplus_api_config.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.firestore_sa.email}"
}

# Build and push CMS container images using Cloud Build
resource "null_resource" "build_and_push_cms" {
  triggers = {
    # This trigger ensures the build runs whenever CMS source code changes.
    cms_source_hash = local.cms_source_hash
    recaptcha_key   = local.effective_recaptcha_site_key
  }

  provisioner "local-exec" {
    # The command is run from the /tofu directory, so we go up one level to the project root.
    # reCAPTCHA site key and Firebase API key are sourced from the shared Firebase stack via terraform_remote_state
    command = "gcloud builds submit --config ../cloudbuild-cms.yaml --substitutions=_REGION=${var.region},_REPO_NAME=${google_artifact_registry_repository.services.name},_SOURCE_HASH=${local.cms_image_tag},_RECAPTCHA_SITE_KEY=${local.effective_recaptcha_site_key},_FIREBASE_API_KEY=${local.effective_identity_api_key} --project=${var.project_id} --service-account=projects/${var.project_id}/serviceAccounts/${google_service_account.cloud_build.email} --default-buckets-behavior=REGIONAL_USER_OWNED_BUCKET .."
  }

  depends_on = [
    google_project_service.cloud_build_api,
    google_artifact_registry_repository.services,
    google_service_account.cloud_build
  ]
}

# Build and push bootstrap container image using Cloud Build
resource "null_resource" "build_and_push_bootstrap" {
  triggers = {
    # Rebuild bootstrap image whenever bootstrap-related sources change.
    bootstrap_source_hash = local.bootstrap_source_hash
  }

  provisioner "local-exec" {
    # The command is run from the /tofu directory, so we go up one level to the project root.
    command = "gcloud builds submit --config ../cloudbuild-bootstrap.yaml --substitutions=_REGION=${var.region},_REPO_NAME=${google_artifact_registry_repository.services.name},_SOURCE_HASH=${local.bootstrap_image_tag} --project=${var.project_id} .."
  }

  depends_on = [
    google_project_service.cloud_build_api,
    google_artifact_registry_repository.services
  ]
}

# Build and push API container images using Cloud Build
resource "null_resource" "build_and_push_api" {
  triggers = {
    # This trigger ensures the build runs whenever API source code changes.
    api_source_hash = local.api_source_hash
  }

  provisioner "local-exec" {
    # The command is run from the /tofu directory, so we go up one level to the project root.
    command = "gcloud builds submit --config ../cloudbuild-api.yaml --substitutions=_REGION=${var.region},_REPO_NAME=${google_artifact_registry_repository.services.name},_SOURCE_HASH=${local.api_image_tag} --project=${var.project_id} --service-account=projects/${var.project_id}/serviceAccounts/${google_service_account.cloud_build.email} --default-buckets-behavior=REGIONAL_USER_OWNED_BUCKET .."
  }

  depends_on = [
    google_project_service.cloud_build_api,
    google_artifact_registry_repository.services,
    google_service_account.cloud_build
  ]
}

# Grant required permissions
# This is needed for new projects, especially personal/free-tier accounts
data "google_project" "current" {}

# Cloud Build service account IAM permissions
resource "google_project_iam_member" "cloudbuild_service_usage_admin" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_iam_admin" {
  project = var.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_firestore_admin" {
  project = var.project_id
  role    = "roles/datastore.owner"
  member  = "serviceAccount:${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
}


resource "google_project_service" "servicecontrol" {
  project            = var.project_id
  service            = "servicecontrol.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "servicemanagement" {
  project            = var.project_id
  service            = "servicemanagement.googleapis.com"
  disable_on_destroy = false
}

# Firestore API is enabled, database will be created automatically

# PoE Request Processing via Cloud Tasks
# NOTE: Cloud Tasks queues have 3-day deletion cooldown - use resource_suffix to avoid conflicts
resource "google_cloud_tasks_queue" "poe_request_queue" {
  name     = "${local.full_prefix}-poe-request-queue${local.queue_suffix}"
  location = var.region
  project  = var.project_id

  rate_limits {
    max_concurrent_dispatches = 5
    max_dispatches_per_second = 5
  }

  retry_config {
    max_attempts       = 3
    max_retry_duration = "600s"
    min_backoff        = "5s"
    max_backoff        = "30s"
  }

  depends_on = [google_project_service.cloud_tasks_api]
}

# User Service Service Account
resource "google_service_account" "user_sa" {
  account_id   = "${local.full_prefix}-user-sa"
  display_name = "User Service Service Account for ${local.full_prefix}"
  project      = var.project_id
}

# Grant user service account access to Cloud Tasks (for PoE queue enqueuing)
resource "google_project_iam_member" "user_sa_cloud_tasks_enqueuer" {
  project = var.project_id
  role    = "roles/cloudtasks.enqueuer"
  member  = "serviceAccount:${google_service_account.user_sa.email}"
}

# Grant user service account permission to act as itself (for Cloud Tasks authentication)
resource "google_service_account_iam_member" "user_sa_act_as" {
  service_account_id = google_service_account.user_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.user_sa.email}"
}

# Grant firestore_sa permission to act as user_sa (for creating Cloud Tasks with user_sa credentials)
resource "google_service_account_iam_member" "firestore_sa_act_as_user_sa" {
  service_account_id = google_service_account.user_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.firestore_sa.email}"
}

# Allow user service account to invoke the PoE service (for OIDC authentication from Cloud Tasks)
# This is needed for the /poe-request/process endpoint
resource "google_cloud_run_v2_service_iam_member" "poe_invoker_for_rewards" {
  name     = google_cloud_run_v2_service.poe_service.name
  location = google_cloud_run_v2_service.poe_service.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.user_sa.email}"
}
