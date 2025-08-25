variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "external_proxy_network_name" {
  type = string
}

variable "external_proxy_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "internal_only_network_name" {
  type = string
}

variable "internal_only_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "firehose_network_name" {
  type = string
}

variable "firehose_subnet_cidr" {
  type    = string
  default = "10.0.3.0/24"
}
