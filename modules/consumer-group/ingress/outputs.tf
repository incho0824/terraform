output "bucket_name" {
  value = google_storage_bucket.static.name
}

output "load_balancer_ip" {
  value = google_compute_global_address.lb_ip.address
}
