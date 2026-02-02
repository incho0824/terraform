output "firebase_project_id" {
  description = "Firebase-linked GCP project ID"
  value       = google_firebase_project.default.project
}

output "identity_platform_sign_in" {
  description = "Enabled sign-in providers"
  value       = google_identity_platform_config.default.sign_in
}

output "firebase_browser_api_key" {
  description = "Firebase browser API key value (sensitive)"
  value       = google_apikeys_key.firebase_browser.key_string
  sensitive   = true
}

output "firebase_browser_api_key_name" {
  description = "Firebase browser API key resource name"
  value       = google_apikeys_key.firebase_browser.name
}

output "recaptcha_enterprise_key_name" {
  description = "reCAPTCHA Enterprise key resource name"
  value       = google_recaptcha_enterprise_key.sms_auth.name
}

output "recaptcha_site_key" {
  description = "reCAPTCHA Enterprise site key (public)"
  value       = element(split("/", google_recaptcha_enterprise_key.sms_auth.name), length(split("/", google_recaptcha_enterprise_key.sms_auth.name)) - 1)
}

output "shared_vpc_id" {
  description = "Self-link of the shared VPC network"
  value       = google_compute_network.shared_vpc.id
}

output "shared_app_subnet_id" {
  description = "Self-link of the shared app subnet"
  value       = google_compute_subnetwork.shared_app_subnet.id
}

output "shared_app_subnet_name" {
  description = "Name of the shared app subnet"
  value       = google_compute_subnetwork.shared_app_subnet.name
}

output "firestore_database_name" {
  description = "Firestore database name (typically (default))"
  value       = google_firestore_database.default.name
}
