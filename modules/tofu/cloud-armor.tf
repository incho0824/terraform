resource "google_compute_security_policy" "baseline-security-policy" {
  provider    = google-beta
  name        = "${local.full_prefix}-baseline-security-policy"
  description = "Security policy to protect backend services"

  # Rate limit rule
  rule {
    action      = "throttle" # Use 'throttle' for rate limiting
    priority    = "1004"
    description = "Rate limit to 600 requests per minute per IP"

    match {
      versioned_expr = "SRC_IPS_V1" # Applies to source IP addresses
      config {
        src_ip_ranges = ["0.0.0.0/0"] # Apply to all source IPs
      }
    }

    rate_limit_options {
      # The maximum number of requests allowed during the interval
      rate_limit_threshold {
        count        = 600
        interval_sec = 60 # 60 seconds = 1 minute
      }
      # The amount of time the client will be blocked after exceeding the limit
      conform_action = "allow"     # Action if traffic is within limit
      exceed_action  = "deny(429)" # Action if traffic exceeds limit (HTTP 429 Too Many Requests)
      # enforce_on_key = "IP" # Default, or can be "HTTP_HEADER", "COOKIE", etc.
      # Exceed action HTTP Status Code
      enforce_on_key = "IP"
    }
  }

  # Default rule: allow all traffic that doesn't match other rules
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }

}

