provider "google" {
  project               = var.project_id
  region                = var.region
  user_project_override = true
  billing_project       = var.project_id
}

provider "google-beta" {
  project               = var.project_id
  region                = var.region
  user_project_override = true
  billing_project       = var.project_id
}

locals {
  cloud_project_prefix = var.cloud_project == "TCCC" ? "fm30-" : ""
}

# Link the existing GCP project with Firebase
resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id

}

# Configure Identity Platform for email/password + phone/SMS login
resource "google_identity_platform_config" "default" {
  provider = google-beta

  autodelete_anonymous_users = false
  authorized_domains         = var.firebase_authorized_domains
  depends_on                 = [google_firebase_project.default]

  sign_in {
    email {
      enabled           = true
      password_required = true
    }

    phone_number {
      enabled            = true
      test_phone_numbers = var.identity_platform_test_phone_numbers
    }
  }

  dynamic "multi_tenant" {
    for_each = var.identity_platform_multi_tenant_enabled ? [1] : []
    content {
      allow_tenants = true
    }
  }

  lifecycle {
    ignore_changes = [
      authorized_domains,
      quota,
    ]
  }
}

# Firebase Browser API key (auto-generated or imported)
# After import, we ignore all changes to this resource since it's managed by Google Cloud
resource "google_apikeys_key" "firebase_browser" {
  provider = google-beta

  name         = "placeholder-ignored-after-import"
  display_name = "Browser key (auto created by Firebase)"
  project      = var.project_id

  restrictions {
    api_targets {
      service = "identitytoolkit.googleapis.com"
    }
  }

  depends_on = [
    google_identity_platform_config.default
  ]

  lifecycle {
    ignore_changes = [name, project, restrictions]
  }
}

resource "google_recaptcha_enterprise_key" "sms_auth" {
  provider     = google-beta
  display_name = "Identity Platform reCAPTCHA integration (web)"
  project      = var.project_id

  web_settings {
    integration_type = "SCORE"
    allowed_domains  = ["localhost", "127.0.0.1"]
  }

  lifecycle {
    ignore_changes = [
      web_settings,
      display_name,
    ]
  }
}

resource "google_compute_network" "shared_vpc" {
  name                    = "${local.cloud_project_prefix}shared-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "shared_app_subnet" {
  name          = "${local.cloud_project_prefix}shared-${var.region}-subnet"
  ip_cidr_range = var.shared_app_subnet_cidr
  region        = var.region
  network       = google_compute_network.shared_vpc.id
  project       = var.project_id

  # VPC Flow Logs - COMPREHENSIVE tier (100% sampling)
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_project_service" "service_networking" {
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_global_address" "shared_sql_private_range" {
  name          = "${local.cloud_project_prefix}shared-sql-private-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.shared_vpc.id
  project       = var.project_id
}

resource "google_service_networking_connection" "shared_sql_psa" {
  network                 = google_compute_network.shared_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.shared_sql_private_range.name]
  depends_on              = [google_project_service.service_networking]
}
