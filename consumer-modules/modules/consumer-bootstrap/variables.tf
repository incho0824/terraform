variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "repository_id" {
  type = string
}

variable "repository_format" {
  type = string
  default = "DOCKER"
}

variable "state_bucket_name" {
  type = string
}

variable "location" {
  type = string
  default = "US"
}

variable "service_account_id" {
  type = string
}