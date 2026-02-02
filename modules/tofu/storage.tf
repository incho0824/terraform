###############################
# Cloud Storage Buckets
###############################

# Cloud Storage buckets for restaurant processing
resource "google_storage_bucket" "restaurants_input" {
  name     = "${local.full_prefix}-restaurants-input"
  location = var.region
  project  = var.project_id

  uniform_bucket_level_access = true
  force_destroy               = !var.is_production

  depends_on = [google_project_service.storage_api]
}

resource "google_storage_bucket" "restaurants_processed" {
  name     = "${local.full_prefix}-restaurants-processed"
  location = var.region
  project  = var.project_id

  uniform_bucket_level_access = true
  force_destroy               = !var.is_production

  depends_on = [google_project_service.storage_api]
}

###############################
# Assets Storage + CDN
###############################

# Assets bucket (restaurants, users, etc. - organized by prefixes)
resource "google_storage_bucket" "assets" {
  name     = "${local.full_prefix}-foodmarks-assets"
  location = var.region
  project  = var.project_id

  uniform_bucket_level_access = true
  force_destroy               = !var.is_production

  cors {
    origin          = ["*"]
    method          = ["GET"]
    response_header = ["Content-Type", "Cache-Control"]
    max_age_seconds = 3600
  }

  depends_on = [google_project_service.storage_api]
}

# CDN Backend Bucket for Assets
resource "google_compute_backend_bucket" "assets_cdn" {
  project     = var.project_id
  name        = "${local.full_prefix}-assets-cdn"
  bucket_name = google_storage_bucket.assets.name
  enable_cdn  = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 7200  # 2 hours
    max_ttl           = 86400 # 24 hours
    client_ttl        = 7200  # 2 hours
    serve_while_stale = 86400 # Serve stale content for up to 24h while revalidating
  }
}
