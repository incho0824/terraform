locals {
  neg_configs = merge([
    for backend_key, backend in var.backends : {
      for idx, neg in try(backend.serverless_neg_backends, []) :
      "${backend_key}-neg-${idx}" => {
        project_id = try(backend.project, null)
        cloudrun = {
          region         = neg.region
          target_service = { name = neg.service.name }
        }
      }
      if neg.type == "cloud-run"
    }
  ]...)

  backend_service_configs = {
    for backend_key, backend in var.backends : backend_key => {
      project_id      = try(backend.project, null)
      protocol        = try(backend.protocol, null)
      enable_cdn      = try(backend.enable_cdn, null)
      security_policy = try(backend.security_policy, null)
      log_sample_rate = try(backend.log_config.enable, false) ? 1 : null
      iap_config      = try(backend.iap_config, null)
      backends = [
        for idx, neg in try(backend.serverless_neg_backends, []) : {
          backend = "${backend_key}-neg-${idx}"
        }
        if neg.type == "cloud-run"
      ]
    }
  }

  converted_path_matchers = {
    for path_matcher_key, path_matcher in var.path_matchers : path_matcher_key => {
      default_service = path_matcher.default_service
      path_rules      = try(path_matcher.rules, [])
      route_rules = [
        for route_rule in try(path_matcher.route_rules, []) : {
          priority = route_rule.priority
          service  = route_rule.service
          match_rules = [
            for match_rule in try(route_rule.match_rules, []) : {
              path = (
                try(match_rule.full_path_match, null) != null
                ? { type = "full", value = match_rule.full_path_match }
                : try(match_rule.prefix_match, null) != null
                ? { type = "prefix", value = match_rule.prefix_match }
                : null
              )
              headers = [
                for header_match in try(match_rule.header_matches, []) : {
                  name  = header_match.header_name
                  type  = try(header_match.exact_match, null) != null ? "exact" : "present"
                  value = try(header_match.exact_match, null)
                }
              ]
            }
          ]
        }
      ]
    }
  }
}

module "lb" {
  source = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-lb-app-ext?ref=${var.fabric_version}"

  project_id = var.project_id
  name       = var.lb_name

  use_classic_version = var.load_balancing_scheme == "EXTERNAL_MANAGED" ? false : true
  protocol            = var.ssl ? "HTTPS" : "HTTP"

  forwarding_rules_config = {
    default = {
      address = var.ip_address
    }
  }

  https_proxy_config = var.ssl ? {
    certificate_map = var.certificate_map
  } : {}

  neg_configs              = local.neg_configs
  backend_service_configs  = local.backend_service_configs
  backend_buckets_config   = var.backend_buckets

  urlmap_config = {
    default_service = var.default_service_key
    host_rules      = var.host_rules
    path_matchers   = local.converted_path_matchers
  }
}
