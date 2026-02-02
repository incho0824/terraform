variable "project_id" {
  description = "GCP project ID where shared resources live"
  type        = string
}

variable "region" {
  description = "Region used for regional resources like state bucket"
  type        = string
  default     = "us-central1"
}

variable "shared_app_subnet_cidr" {
  description = "CIDR range for the shared application subnet used by Cloud Run VPC egress"
  type        = string
  default     = "10.20.0.0/21"
}

variable "cloud_project" {
  description = "Logical project type (MVP or TCCC) used for naming conventions"
  type        = string
  default     = "MVP"
  validation {
    condition     = contains(["MVP", "TCCC"], var.cloud_project)
    error_message = "cloud_project must be either 'MVP' or 'TCCC'."
  }
}

variable "firebase_authorized_domains" {
  description = "Domains allowed to use Firebase Authentication"
  type        = list(string)
  default     = []
}

variable "identity_platform_test_phone_numbers" {
  description = "Test phone numbers for Identity Platform (map of phone number to verification code)"
  type        = map(string)
  default = {
    "+48960000000" = "012345"
    "+48960000001" = "123456"
    "+48960000002" = "234567"
    "+48960000003" = "345678"
    "+48960000004" = "456789"
    "+48960000005" = "567890"
    "+48960000006" = "678901"
    "+48960000007" = "789012"
    "+48960000008" = "890123"
    "+48960000009" = "901234"
  }
}

variable "identity_platform_multi_tenant_enabled" {
  description = "Enable multi-tenant support in Identity Platform"
  type        = bool
  default     = true
}

variable "identity_platform_signup_quota" {
  description = "Daily signup quota limit"
  type        = number
  default     = 1000
}

variable "identity_platform_signup_quota_duration" {
  description = "Quota duration in seconds (default 86400s = 24 hours)"
  type        = string
  default     = "86400s"
}
