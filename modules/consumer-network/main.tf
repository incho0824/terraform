resource "google_compute_network" "external_proxy_vpc" {
  name = var.external_proxy_network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "external_proxy_subnet" {
  name = "${var.external_proxy_network_name}-subnet"
  ip_cidr_range = var.external_proxy_subnet_cidr
  network = google_compute_network.external_proxy_vpc.id
}

resource "google_compute_network" "internal_only_vpc" {
  name = var.internal_only_network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "internal_only_subnet" {
  name = "${var.internal_only_network_name}-subnet"
  ip_cidr_range = var.internal_only_subnet_cidr
  network = google_compute_network.internal_only_vpc.id
}

resource "google_compute_network" "firehose_vpc" {
  name = var.firehose_network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "firehose_subnet" {
  name = "${var.firehose_network_name}-subnet"
  ip_cidr_range = var.firehose_subnet_cidr
  network = google_compute_network.firehose_vpc.id
}