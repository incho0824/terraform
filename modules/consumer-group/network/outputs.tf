output "external_proxy_network_id" {
  value = google_compute_network.external_proxy_vpc.id
}

output "external_proxy_subnet_id" {
  value = google_compute_subnetwork.external_proxy_subnet.id
}

output "internal_only_network_id" {
  value = google_compute_network.internal_only_vpc.id
}

output "internal_only_subnet_id" {
  value = google_compute_subnetwork.internal_only_subnet.id
}

output "firehose_network_id" {
  value = google_compute_network.firehose_vpc.id
}

output "firehose_subnet_id" {
  value = google_compute_subnetwork.firehose_subnet.id
}
