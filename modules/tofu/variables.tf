variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (alpha, beta, gamma, prod)"
  type        = string
  default     = "gamma"
}


variable "developer_prefix" {
  description = "Developer-specific prefix for resource names to avoid conflicts"
  type        = string
  default     = ""
}

variable "environment_prefix" {
  description = "Environment prefix for resource names (e.g., dev, staging, prod)"
  type        = string
  default     = ""
}

variable "resource_suffix" {
  description = "Suffix for GCP resources with deletion cooldown (e.g., Cloud Tasks queues have 3-day cooldown). Increment this (v1->v2) after tofu destroy to avoid name conflicts on next tofu apply."
  type        = string
  default     = ""
}

variable "cloud_project" {
  description = "Cloud project (MVP or TCCC) - affects resource naming"
  type        = string
  default     = "MVP"
  nullable    = false
  validation {
    condition     = contains(["MVP", "TCCC"], var.cloud_project)
    error_message = "cloud_project must be either 'MVP' or 'TCCC'."
  }
}

variable "is_production" {
  description = "Whether this is a production deployment. Controls deletion_protection on Cloud SQL and other critical resources. Override to false in tfvars for ephemeral dev environments."
  type        = bool
  default     = true
}

variable "service_name" {
  description = "Name of the Cloud Run service"
  type        = string
  default     = "backend-service"
}

variable "image_tag" {
  description = "Docker image tag for container deployments"
  type        = string
  default     = "latest"
}

variable "google_maps_api_key" {
  description = "Google Maps API key for geocoding services"
  type        = string
  sensitive   = true
}

variable "promoplus_api_url" {
  description = "PromoPlus API URL for promotion services"
  type        = string
  sensitive   = false
}

variable "promoplus_api_key" {
  description = "PromoPlus API key for authentication with promotion services"
  type        = string
  sensitive   = true
}

variable "promoplus_config_id" {
  description = "PromoPlus configuration ID for promotion services"
  type        = string
  sensitive   = false
}

variable "promoplus_sts_key_id" {
  description = "PromoPlus STS key ID for authentication with promotion services"
  type        = string
  sensitive   = true
}

variable "promoplus_sts_secret" {
  description = "PromoPlus STS secret for authentication with promotion services"
  type        = string
  sensitive   = true
}

variable "promoplus_sts_region" {
  description = "PromoPlus STS region for authentication with promotion services"
  type        = string
  sensitive   = false
}

variable "data_retrieval_user" {
  description = "Username for data retrieval scheduler authentication"
  type        = string
  sensitive   = true
}

variable "data_retrieval_password" {
  description = "Password for data retrieval scheduler authentication"
  type        = string
  sensitive   = true
}

variable "google_custom_search_api_key" {
  description = "Google Custom Search API key for image downloading"
  type        = string
  sensitive   = true
}

variable "google_custom_search_engine_id" {
  description = "Google Custom Search Engine ID for image search"
  type        = string
  sensitive   = true
}

variable "poe_config" {
  description = "POE (Points of Engagement) service configuration as JSON string"
  type        = string
  sensitive   = true
}

variable "sql_proxy" {
  description = "Enable public IP for Cloud SQL Proxy access (local development). When true, enables public IP with IAM authentication only (no IP whitelisting)."
  type        = bool
  default     = false
}

variable "lb_domain_name_suffix" {
  description = "The domain name suffix for the load balancer."
  type        = string
  default     = "tccc-foodmarks.wttech.cloud"
}