project_id         = "cdp-team-poc"
network_project_id = "cdp-team-poc"
mgmt_project_id    = "cdp-team-poc"
network            = "sample-network"

ilb_subnet_primary   = "c4p-cds-product-pri-ilb-snet"
ilb_subnet_secondary = "c4p-cds-product-sec-ilb-snet"
psc_subnet_primary   = "c4p-cds-product-pri-psc-snet"
psc_subnet_secondary = "c4p-cds-product-sec-psc-snet"

state_bucket = "c4p-cds-product-alpha-staging-bucket"
geo          = "product"
app_code     = "cds"
environment  = "alpha"

deploy_primary   = true
deploy_secondary = false

create_lb_marketing_primary   = true
create_lb_marketing_secondary = false
create_lb_dedicated_api_edge  = true
create_lb_marketing_api_edge  = true

sm_vkey_creds_secret_data                         = "sample"
sm_fraud_configs_secret_data                      = "sample"
sm_gateway_creds_secret_data                      = "sample"
sm_meta_access_token_secret_data                  = "sample"
sm_meta_verify_token_secret_data                  = "sample"
sm_recaptcha_config_secret_data                   = "sample"
sm_prospect_ingestion_oauth_parameter_secret_data = "sample"

spn_main_instance = {
  instance_config      = "regional-us-central1"
  edition = "ENTERPRISE"
  num_nodes = 1
  instance_type = "PROVISIONED"
  enable_autoscaling   = false
  default_backup_schedule_type = "NONE"
  force_destroy = false
  # min_processing_units = 100
  # max_processing_units = 200
}

spn_main_instance_consumer_db_backup = {
  retention_duration = "2592000s"
  cron_spec_text     = "0 2 * * *"
  use_full_backup_spec = true
  use_incremental_backup_spec = false
}

spn_main_instance_consumer_db = {
  name = "consumer"
  database_dialect = "GOOGLE_STANDARD_SQL"
  enable_drop_protection = false
  deletion_protection = false
  default_time_zone = "America/Los_Angeles"
}

fs_main_database = {
  location      = "us-central1"
  database_type = "FIRESTORE_NATIVE"
  database_edition = "STANDARD"
  deletion_policy = "DELETE"
}

vkey_main_primary = {
  engine_version                = "VALKEY_8_0"
  shard_count                   = 1
  zone_distribution_config_mode = "SINGLE_ZONE"
  authorization_mode            = "IAM_AUTH"
  deletion_protection_enabled   = false
}

vkey_main_secondary = {
  engine_version                = "VALKEY_7_2"
  shard_count                   = 3
  zone_distribution_config_mode = "MULTI_ZONE"
  authorization_mode            = "AUTH_MODE_IAM_AUTH"
  deletion_protection_enabled   = true
}

gcs_exp_configs = {
  location                    = "us-central1"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true
}

gcs_prospect_configs = {
  location                    = "us-central1"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true
}

gcs_prospect_dropzone = {
  location                    = "us-central1"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true
}

gcs_privacy_configs = {
  location                    = "us-central1"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true
}

gcs_privacy_consumer_archive = {
  location                    = "us-central1"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true
}

gcs_aadb2c_event_dropzone = {
  location                    = "us-central1"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true
}

gcs_exp_templates = {
  location                    = "us-central1"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true
}

gcs_aad_b2c_component_cdn = {
  location                    = "us-central1"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true
}

gcs_aad_b2c_component_demo = {
  location                    = "us-central1"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true
}

gcs_aad_b2c_component_account = {
  location                    = "us-central1"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true
}

gcs_consumer_gamv2_demo_site = {
  location                    = "us-central1"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true
}

gcs_processor_configs = {
  location                    = "us-central1"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true
}

wildcard_domain            = "alpha.global.gcds.coke.com"
prospect_domain            = "prospect.alpha.global.gcds.coke.com"
internal_services_hostname = "internal-gcp"
aadb2c_services_hostname   = "aadb2c-gcp"
