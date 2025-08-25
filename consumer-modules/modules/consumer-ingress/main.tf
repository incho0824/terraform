resource "google_storage_bucket" "static" {
  name = var.bucket_name
  location = var.location
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.static.name
  role = "roles/storage.objectViewer"
  member = var.member
}

resource "google_cloud_run_service" "service" {
  name = var.cloud_run_service_name
  location = var.region

  template {
    spec {
      containers {
        image = var.cloud_run_image
      }
    }
  }

  traffic {
    percent = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "invoker" {
  project = google_cloud_run_service.service.project
  location = google_cloud_run_service.service.location
  service = google_cloud_run_service.service.name
  role = "roles/run.invoker"
  member = var.member
}

resource "google_compute_region_network_endpoint_group" "run_neg" {
  name = "${var.cloud_run_service_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region = var.region
  cloud_run {
    service = google_cloud_run_service.service.name
  }
}

resource "google_compute_backend_service" "run_backend" {
  name = "${var.cloud_run_service_name}-backend"
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_region_network_endpoint_group.run_neg.id
  }
}

resource "google_compute_backend_bucket" "bucket_backend" {
  name = "${var.bucket_name}-backend"
  bucket_name = google_storage_bucket.static.name
  enable_cdn = true
}

resource "google_compute_url_map" "default" {
  name = "${var.project_id}-url-map"
  default_service = google_compute_backend_bucket.bucket_backend.id

  host_rule {
    hosts = [var.domain]
    path_matcher = "allpaths"
  }

  path_matcher {
    name = "allpaths"
    default_service = google_compute_backend_bucket.bucket_backend.id

    path_rule {
      paths = [var.api_path]
      service = google_compute_backend_service.run_backend.id
    }
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "${var.project_id}-cert"

  managed {
    domains = [var.domain]
  }
}

resource "google_compute_target_https_proxy" "default" {
  name = "${var.project_id}-https-proxy"
  url_map = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_global_address" "lb_ip" {
  name = "${var.project_id}-lb-ip"
}

resource "google_compute_global_forwarding_rule" "https" {
  name = "${var.project_id}-https-fr"
  target = google_compute_target_https_proxy.default.id
  port_range = "443"
  load_balancing_scheme = "EXTERNAL"
  ip_address = google_compute_global_address.lb_ip.address
}