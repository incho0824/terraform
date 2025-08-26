# Enable Compute Engine API
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

# External proxy network and subnet
resource "google_compute_network" "external_proxy_vpc" {
  project                 = var.project_id
  name                    = var.external_proxy_network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "external_proxy_subnet" {
  project       = var.project_id
  name          = "${var.external_proxy_network_name}-subnet"
  ip_cidr_range = var.external_proxy_subnet_cidr
  network       = google_compute_network.external_proxy_vpc.id
  region        = var.region
}

# Internal only network and subnet
resource "google_compute_network" "internal_only_vpc" {
  project                 = var.project_id
  name                    = var.internal_only_network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "internal_only_subnet" {
  project       = var.project_id
  name          = "${var.internal_only_network_name}-subnet"
  ip_cidr_range = var.internal_only_subnet_cidr
  network       = google_compute_network.internal_only_vpc.id
  region        = var.region
}

# Firehose network and subnet
resource "google_compute_network" "firehose_vpc" {
  project                 = var.project_id
  name                    = var.firehose_network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "firehose_subnet" {
  project       = var.project_id
  name          = "${var.firehose_network_name}-subnet"
  ip_cidr_range = var.firehose_subnet_cidr
  network       = google_compute_network.firehose_vpc.id
  region        = var.region
}
