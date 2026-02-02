# Firestore composite indexes for checkins queries
resource "google_firestore_index" "checkins_user_date_index" {
  project = var.project_id

  collection = "${local.full_prefix}-checkins"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "date"
    order      = "DESCENDING"
  }

  depends_on = [null_resource.firestore_database_default]
}

# Firestore composite index for mission status queries
resource "google_firestore_index" "mission_status_user_updated_index" {
  project = var.project_id

  collection = "${local.full_prefix}-mission-status"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "updated_at"
    order      = "DESCENDING"
  }

  depends_on = [null_resource.firestore_database_default]
}

# Firestore composite index for mission status queries by user and city name
# Supports queries like:
#   where('user_id', '==', userId)
#   where('city_names', 'array-contains', cityName)
#   orderBy('updated_at', 'desc')
resource "google_firestore_index" "mission_status_user_city_names_updated_index" {
  project = var.project_id

  collection = "${local.full_prefix}-mission-status"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path   = "city_names"
    array_config = "CONTAINS"
  }

  fields {
    field_path = "updated_at"
    order      = "DESCENDING"
  }

  depends_on = [null_resource.firestore_database_default]
}

# Firestore composite index for redemption stats queries
resource "google_firestore_index" "redemption_log_restaurant_index" {
  project = var.project_id

  collection = "${local.full_prefix}-redemption-log"

  fields {
    field_path = "restaurant_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "status"
    order      = "ASCENDING"
  }

  fields {
    field_path = "date"
    order      = "ASCENDING"
  }

  depends_on = [null_resource.firestore_database_default]
}

resource "google_firestore_index" "checkins_restaurant_date_index" {
  project = var.project_id

  collection = "${local.full_prefix}-checkins"

  fields {
    field_path = "restaurant_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "date"
    order      = "ASCENDING"
  }

  depends_on = [null_resource.firestore_database_default]
}


# Firestore composite index for redemption log queries
resource "google_firestore_index" "redemption_log_user_status_index" {
  project = var.project_id

  collection = "${local.full_prefix}-redemption-log"

  fields {
    field_path = "userId"
    order      = "ASCENDING"
  }

  fields {
    field_path = "status"
    order      = "ASCENDING"
  }
}

# Firestore composite index for saved restaurants queries (preferences)
resource "google_firestore_index" "profile_user_market_index" {
  project = var.project_id

  collection = "${local.full_prefix}-profile"

  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }

  fields {
    field_path = "market"
    order      = "ASCENDING"
  }
}
