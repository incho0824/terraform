# Storage bucket for static content and access
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

# External HTTPS load balancer
resource "google_compute_region_network_endpoint_group" "run_neg" {
  project               = var.project_id
  name                  = "${var.cloud_run_service_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = var.cloud_run_service_name
  }
}

resource "google_compute_backend_service" "run_backend" {
  project               = var.project_id
  name                  = "${var.cloud_run_service_name}-backend"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_region_network_endpoint_group.run_neg.id
  }
}

resource "google_compute_backend_bucket" "bucket_backend" {
  project     = var.project_id
  name        = "${var.bucket_name}-backend"
  bucket_name = google_storage_bucket.static.name
  enable_cdn  = true
}

resource "google_compute_url_map" "default" {
  project         = var.project_id
  name            = "${var.project_id}-url-map"
  default_service = google_compute_backend_bucket.bucket_backend.id

  host_rule {
    hosts        = [var.domain]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.bucket_backend.id

    path_rule {
      paths   = [var.api_path]
      service = google_compute_backend_service.run_backend.id
    }
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  project = var.project_id
  name    = "${var.project_id}-cert"

  managed {
    domains = [var.domain]
  }
}

resource "google_compute_target_https_proxy" "default" {
  project          = var.project_id
  name             = "${var.project_id}-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_global_address" "lb_ip" {
  project = var.project_id
  name    = "${var.project_id}-lb-ip"
}

resource "google_compute_global_forwarding_rule" "https" {
  project               = var.project_id
  name                  = "${var.project_id}-https-fr"
  target                = google_compute_target_https_proxy.default.id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.lb_ip.address
}
