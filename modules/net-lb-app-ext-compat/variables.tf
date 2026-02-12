variable "fabric_version" {
  type = string
}

variable "project_id" {
  type = string
}

variable "lb_name" {
  type = string
}

variable "load_balancing_scheme" {
  type    = string
  default = "EXTERNAL_MANAGED"
}

variable "https_redirect" {
  type    = bool
  default = false
}

variable "ssl" {
  type    = bool
  default = false
}

variable "certificate_map" {
  type    = string
  default = null
}

variable "ip_address" {
  type    = string
  default = null
}

variable "default_service_key" {
  type = string
}

variable "backends" {
  type = map(object({
    project         = optional(string)
    protocol        = optional(string)
    enable_cdn      = optional(bool)
    security_policy = optional(string)
    log_config = optional(object({
      enable = optional(bool)
    }))
    iap_config = optional(any)
    serverless_neg_backends = optional(list(object({
      region  = string
      type    = string
      service = object({ name = string })
    })), [])
  }))
  default = {}
}

variable "backend_buckets" {
  type    = any
  default = {}
}

variable "path_matchers" {
  type = map(object({
    default_service = string
    rules = optional(list(object({
      paths   = list(string)
      service = string
    })), [])
    route_rules = optional(list(any), [])
  }))
}

variable "host_rules" {
  type = list(object({
    hosts        = list(string)
    path_matcher = string
  }))
  default = []
}
