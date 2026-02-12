project_id         = "sample-project"
network_project_id = "sample-network-project"
mgmt_project_id    = "sample-mgmt-project"
network            = "projects/sample-network-project/global/networks/sample-vpc"

ilb_subnet_primary   = "projects/sample-network-project/regions/us-central1/subnetworks/sample-ilb-primary"
ilb_subnet_secondary = "projects/sample-network-project/regions/us-east1/subnetworks/sample-ilb-secondary"
psc_subnet_primary   = "projects/sample-network-project/regions/us-central1/subnetworks/sample-psc-primary"
psc_subnet_secondary = "projects/sample-network-project/regions/us-east1/subnetworks/sample-psc-secondary"

state_bucket = "sample-state-bucket"
geo          = "product"
app_code     = "cds"
environment  = "gamma"

deploy_primary   = true
deploy_secondary = true

create_lb_marketing_primary   = true
create_lb_marketing_secondary = true
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
  enable_autoscaling   = true
  min_processing_units = 100
  max_processing_units = 200
}

spn_main_instance_consumer_db_backup = {
  retention_duration = "86400s"
  cron_spec_text     = "0 3 * * *"
}

spn_main_instance_consumer_db = {
  name = "consumerdb"
}

fs_main_database = {
  location      = "nam5"
  database_type = "FIRESTORE_NATIVE"
}

vkey_main_primary = {
  engine_version                = "VALKEY_7_2"
  shard_count                   = 3
  zone_distribution_config_mode = "MULTI_ZONE"
  authorization_mode            = "AUTH_MODE_IAM_AUTH"
  deletion_protection_enabled   = true
}

vkey_main_secondary = {
  engine_version                = "VALKEY_7_2"
  shard_count                   = 3
  zone_distribution_config_mode = "MULTI_ZONE"
  authorization_mode            = "AUTH_MODE_IAM_AUTH"
  deletion_protection_enabled   = true
}

gcs_exp_configs = {
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = false
}

gcs_prospect_configs = {
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = false
}

gcs_prospect_dropzone = {
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = false
}

gcs_privacy_configs = {
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = false
}

gcs_privacy_consumer_archive = {
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = false
}

gcs_aadb2c_event_dropzone = {
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = false
}

gcs_exp_templates = {
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = false
}

gcs_aad_b2c_component_cdn = {
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = false
}

gcs_aad_b2c_component_demo = {
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = false
}

gcs_aad_b2c_component_account = {
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = false
}

gcs_consumer_gamv2_demo_site = {
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = false
}

gcs_processor_configs = {
  location                    = "US"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = false
}

wildcard_domain            = "example.com"
prospect_domain            = "prospect.example.com"
internal_services_hostname = "internal.example.com"
aadb2c_services_hostname   = "aadb2c.example.com"
