variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "location" {
  type = string
}

variable "cloud_run_service_name" {
  type = string
}

variable "cloud_run_image" {
  type = string
}

variable "domain" {
  type = string
}

variable "api_path" {
  type    = string
  default = "/api/*"
}

variable "member" {
  type = string
}

variable "enable_mtls" {
  type    = bool
  default = false
}

variable "client_ca" {
  type        = string
  default     = null
  description = "PEM-encoded CA certificate for client authentication when mTLS is enabled"
}
