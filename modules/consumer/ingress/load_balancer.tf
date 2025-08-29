resource "google_compute_region_network_endpoint_group" "run_neg" {
  project               = var.project_id
  name                  = "${var.cloud_run_service_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.service.name
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
  count   = var.enable_mtls ? 0 : 1
  project = var.project_id
  name    = "${var.project_id}-cert"

  managed {
    domains = [var.domain]
  }
}

resource "google_certificate_manager_certificate" "mtls_cert" {
  count   = var.enable_mtls ? 1 : 0
  project = var.project_id
  name    = "${var.project_id}-cert"

  managed {
    domains = [var.domain]
  }
}

resource "google_certificate_manager_trust_config" "mtls" {
  count   = var.enable_mtls ? 1 : 0
  project = var.project_id
  name    = "${var.project_id}-trust-config"

  trust_stores {
    trust_anchors {
      pem_certificate = var.client_ca
    }
  }
}

resource "google_certificate_manager_certificate_map" "mtls" {
  count   = var.enable_mtls ? 1 : 0
  project = var.project_id
  name    = "${var.project_id}-cert-map"
}

resource "google_certificate_manager_certificate_map_entry" "mtls" {
  count                            = var.enable_mtls ? 1 : 0
  project                          = var.project_id
  name                             = "${var.project_id}-cert-map-entry"
  map                              = google_certificate_manager_certificate_map.mtls[0].name
  hostname                         = var.domain
  certificates                     = [google_certificate_manager_certificate.mtls_cert[0].id]
  certificate_manager_trust_config = google_certificate_manager_trust_config.mtls[0].id
}

resource "google_compute_target_https_proxy" "default" {
  count            = var.enable_mtls ? 0 : 1
  project          = var.project_id
  name             = "${var.project_id}-https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default[0].id]
}

resource "google_compute_target_https_proxy" "mtls" {
  count           = var.enable_mtls ? 1 : 0
  project         = var.project_id
  name            = "${var.project_id}-https-proxy"
  url_map         = google_compute_url_map.default.id
  certificate_map = google_certificate_manager_certificate_map.mtls[0].id
}

resource "google_compute_global_address" "lb_ip" {
  project = var.project_id
  name    = "${var.project_id}-lb-ip"
}

resource "google_compute_global_forwarding_rule" "https" {
  project               = var.project_id
  name                  = "${var.project_id}-https-fr"
  target                = var.enable_mtls ? google_compute_target_https_proxy.mtls[0].id : google_compute_target_https_proxy.default[0].id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.lb_ip.address
}
