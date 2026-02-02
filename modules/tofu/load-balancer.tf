# Create Static IP for the Load Balancer
resource "google_compute_global_address" "global_lb_ip" {
  project      = var.project_id
  name         = "${local.full_prefix}-lb-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  description  = "Global static IP for Load Balancer"
}

# Serverless NEG for Cloud Run Services
resource "google_compute_region_network_endpoint_group" "neg_checkins" {
  project               = var.project_id
  region                = var.region
  provider              = google-beta
  name                  = "${local.full_prefix}-neg-checkins-service"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.checkins_service.name
  }
}

resource "google_compute_region_network_endpoint_group" "neg_cms" {
  project               = var.project_id
  region                = var.region
  provider              = google-beta
  name                  = "${local.full_prefix}-neg-cms-service"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.cms_service.name
  }
}

resource "google_compute_region_network_endpoint_group" "neg_docs" {
  project               = var.project_id
  region                = var.region
  provider              = google-beta
  name                  = "${local.full_prefix}-neg-docs-service"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.docs_service.name
  }
}

resource "google_compute_region_network_endpoint_group" "neg_restaurant_processor" {
  project               = var.project_id
  region                = var.region
  provider              = google-beta
  name                  = "${local.full_prefix}-neg-restaurant-processor-service"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.restaurant_processor_service.name
  }
}

resource "google_compute_region_network_endpoint_group" "neg_restaurant_scheduler" {
  project               = var.project_id
  region                = var.region
  provider              = google-beta
  name                  = "${local.full_prefix}-neg-restaurant-scheduler-service"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.restaurant_scheduler_service.name
  }
}

resource "google_compute_region_network_endpoint_group" "neg_restaurant" {
  project               = var.project_id
  region                = var.region
  provider              = google-beta
  name                  = "${local.full_prefix}-neg-restaurant-service"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.restaurants_service.name
  }
}

resource "google_compute_region_network_endpoint_group" "neg_user" {
  project               = var.project_id
  region                = var.region
  provider              = google-beta
  name                  = "${local.full_prefix}-neg-user-service"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.user_service.name
  }
}

# Backend for Cloud Run Service - Checkins Service
resource "google_compute_backend_service" "backend-checkins-service" {
  project               = var.project_id
  name                  = "${local.full_prefix}-backend-checkins-service"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.baseline-security-policy.id

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  backend {
    group = google_compute_region_network_endpoint_group.neg_checkins.id
  }
}

# Backend for Cloud Run Service - CMS Service
resource "google_compute_backend_service" "backend-cms-service" {
  project               = var.project_id
  name                  = "${local.full_prefix}-backend-cms-service"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.baseline-security-policy.id

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  backend {
    group = google_compute_region_network_endpoint_group.neg_cms.id
  }
}

# Backend for Cloud Run Service - Docs Service
resource "google_compute_backend_service" "backend-docs-service" {
  project               = var.project_id
  name                  = "${local.full_prefix}-backend-docs-service"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.baseline-security-policy.id

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  backend {
    group = google_compute_region_network_endpoint_group.neg_docs.id
  }
}

resource "google_compute_backend_service" "backend-restaurant-processor-service" {
  project               = var.project_id
  name                  = "${local.full_prefix}-backend-restaurant-processor-service"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.baseline-security-policy.id

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  backend {
    group = google_compute_region_network_endpoint_group.neg_restaurant_processor.id
  }
}

resource "google_compute_backend_service" "backend-restaurant-scheduler-service" {
  project               = var.project_id
  name                  = "${local.full_prefix}-backend-restaurant-scheduler-service"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.baseline-security-policy.id

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  backend {
    group = google_compute_region_network_endpoint_group.neg_restaurant_scheduler.id
  }
}

resource "google_compute_backend_service" "backend-restaurant-service" {
  project               = var.project_id
  name                  = "${local.full_prefix}-backend-restaurant-service"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.baseline-security-policy.id

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  backend {
    group = google_compute_region_network_endpoint_group.neg_restaurant.id
  }
}

resource "google_compute_backend_service" "backend-user-service" {
  project               = var.project_id
  name                  = "${local.full_prefix}-backend-user-service"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  security_policy       = google_compute_security_policy.baseline-security-policy.id

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  backend {
    group = google_compute_region_network_endpoint_group.neg_user.id
  }
}

# URL Map for Path-based Routing (Actual Load Balancer)
resource "google_compute_url_map" "lb" {
  project     = var.project_id
  name        = "${local.full_prefix}-lb"
  description = "Load Balancer with URL map for path-based routing to Cloud Run services"

  default_service = google_compute_backend_service.backend-user-service.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.backend-user-service.id

    path_rule {
      paths   = ["/assets/*"]
      service = google_compute_backend_service.backend-cms-service.id
    }

    path_rule {
      paths   = ["/api-docs", "/api-docs/*"]
      service = google_compute_backend_service.backend-docs-service.id
    }

    path_rule {
      paths   = ["/cms", "/cms/*"]
      service = google_compute_backend_service.backend-cms-service.id
    }

    path_rule {
      paths = ["/ph-en/user-profile", "/ph-en/user-profile/*",
        "/in-en/user-profile", "/in-en/user-profile/*",
        "/br-pt/user-profile", "/br-pt/user-profile/*",
        "/br-en/user-profile", "/br-en/user-profile/*",
      "/us-en/user-profile", "/us-en/user-profile/*"]
      service = google_compute_backend_service.backend-user-service.id
    }

    path_rule {
      paths   = ["/checkins", "/checkins/*", "/mission-status", "/mission-status/*"]
      service = google_compute_backend_service.backend-checkins-service.id
    }

    path_rule {
      paths   = ["/processing-scheduler", "/processing-scheduler/*"]
      service = google_compute_backend_service.backend-restaurant-scheduler-service.id
    }

    path_rule {
      paths   = ["/restaurant-processor", "/restaurant-processor/*"]
      service = google_compute_backend_service.backend-restaurant-processor-service.id
    }

    path_rule {
      paths = ["/ph-en/restaurants", "/ph-en/restaurants/search", "/ph-en/restaurants/search/*",
        "/in-en/restaurants", "/in-en/restaurants/search", "/in-en/restaurants/search/*",
        "/br-pt/restaurants", "/br-pt/restaurants/search", "/br-pt/restaurants/search/*",
        "/br-en/restaurants", "/br-en/restaurants/search", "/br-en/restaurants/search/*",
        "/us-en/restaurants", "/us-en/restaurants/search", "/us-en/restaurants/search/*",
      "/zz-en/restaurants", "/zz-en/restaurants/search", "/zz-en/restaurants/search/*"]
      service = google_compute_backend_service.backend-restaurant-service.id
    }
  }
}

# Generate Google Managed SSL Certificate
resource "google_compute_managed_ssl_certificate" "lb-managed-tls-cert" {
  project = var.project_id
  name    = "${local.full_prefix}-lb-managed-tls-cert"
  managed {
    domains = ["${local.full_prefix}.${var.lb_domain_name_suffix}"]
  }
}

# Target HTTPS Proxy
resource "google_compute_target_https_proxy" "lb-https-proxy" {
  project          = var.project_id
  name             = "${local.full_prefix}-https-proxy"
  description      = "HTTPS proxy for Load Balancer"
  url_map          = google_compute_url_map.lb.id
  ssl_certificates = [google_compute_managed_ssl_certificate.lb-managed-tls-cert.id]

}

# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "lb-forwarding-rule" {
  project               = var.project_id
  name                  = "${local.full_prefix}-lb-forwarding-rule"
  target                = google_compute_target_https_proxy.lb-https-proxy.id
  ip_address            = google_compute_global_address.global_lb_ip.address
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# Non TCCC environments only - adding DNS record for the load balancer
resource "google_dns_record_set" "lb_dns_record" {
  project      = var.project_id
  count        = var.cloud_project == "MVP" ? 1 : 0
  managed_zone = "tcc-foodmarks-vml-public-zone" # this is configured outside of tofu
  name         = "${local.full_prefix}.${var.lb_domain_name_suffix}."
  type         = "A"
  ttl          = 60
  rrdatas      = [google_compute_global_address.global_lb_ip.address]
}

#------------------------------------------------------------------------------
# Outputs:
#------------------------------------------------------------------------------
output "load_balancer_ip_address" {
  description = "The IP address of the Global External HTTPS Load Balancer"
  value       = google_compute_global_address.global_lb_ip.address
}

output "load_balancer_url" {
  description = "The URL of the Load Balancer"
  value       = "https://${google_compute_managed_ssl_certificate.lb-managed-tls-cert.managed[0].domains[0]}"
}