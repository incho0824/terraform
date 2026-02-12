locals {
  region_by_geo_type = {
    "PRODUCT" = {
      "PRIMARY"   = var.region_by_geo_type["PRODUCT"].PRIMARY
      "SECONDARY" = var.zone_by_geo_type["PRODUCT"].PRIMARY
    }
  }

  zone_by_geo_type = {
    "PRODUCT" = {
      "PRIMARY"   = var.region_by_geo_type["PRODUCT"].SECONDARY
      "SECONDARY" = var.zone_by_geo_type["PRODUCT"].SECONDARY
    }
  }

  region = local.region_by_geo_type[upper(var.geo)]
  zone   = local.zone_by_geo_type[upper(var.geo)]

  # Whether to create primary/secondary region specific resources. There will be no secondary regions in alpha and beta env
  deploy_primary        = contains(["gamma", "prod"], lower(var.environment)) ? var.deploy_primary : true
  deploy_secondary      = contains(["gamma", "prod"], lower(var.environment)) ? var.deploy_secondary : false
  spanner_instance_name = "${local.resource_name_prefix_global}-spn-main-instance"
  spanner_database_name = var.spn_main_instance_consumer_db.name

  # For gamma and prod, assign regional prefixes. For other environments, keep prefixes empty.
  regional_prefixes                                       = contains(["gamma", "prod"], lower(var.environment)) ? ["-pri", "-sec"] : ["", ""]
  resource_name_prefix_primary                            = format("%s-%s%s", var.environment, var.app_code, local.regional_prefixes[0])
  resource_name_prefix_secondary                          = format("%s-%s%s", var.environment, var.app_code, local.regional_prefixes[1])
  resource_name_prefix_global                             = format("%s-%s", var.environment, var.app_code)
  net_address_module_source                               = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-address?ref=${var.cloud_foundation_fabric_version}"
  global_external_application_load_balancer_module_source = "./modules/net-lb-app-ext-compat"
  internal_application_load_balancer_module_source        = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-lb-app-int?ref=${var.cloud_foundation_fabric_version}"
  gcs_bucket_module_source                                = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git//modules/simple_bucket?ref=${var.cloud_storage_module_version}"
  secret_manager_module_source                            = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/secret-manager?ref=${var.cloud_foundation_fabric_version}"
  firestore_module_source                                 = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/firestore?ref=${var.cloud_foundation_fabric_version}"
  certificate_manager_module_source                       = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/certificate-manager?ref=${var.cloud_foundation_fabric_version}"
  spanner_instance_module_source                          = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/spanner-instance?ref=${var.cloud_foundation_fabric_version}"
  spanner_backup_module_source                            = "git::https://github.com/GoogleCloudPlatform/terraform-google-cloud-spanner.git//modules/schedule_spanner_backup?ref=${var.cloud_spanner_module_version}"
  cloud_armor_module_source                               = "git::https://github.com/GoogleCloudPlatform/terraform-google-cloud-armor.git?ref=${var.cloud_armor_module_version}"
  memorystore_valkey_module_source                        = "git::https://github.com/terraform-google-modules/terraform-google-memorystore.git//modules/valkey?ref=${var.memorystore_module_version}"


  secret_manager_entries = {
    vkey_creds = {
      secret_suffix = "sm-vkey-creds"
      data          = var.sm_vkey_creds_secret_data
    }
    fraud_configs = {
      secret_suffix = "sm-fraud-configs"
      data          = var.sm_fraud_configs_secret_data
    }
    gateway_creds = {
      secret_suffix = "sm-gateway-creds"
      data          = var.sm_gateway_creds_secret_data
    }
    meta_access_token = {
      secret_suffix = "sm-meta-access-token"
      data          = var.sm_meta_access_token_secret_data
    }
    meta_verify_token = {
      secret_suffix = "sm-meta-verify-token"
      data          = var.sm_meta_verify_token_secret_data
    }
    recaptcha_config = {
      secret_suffix = "sm-recaptcha-config"
      data          = var.sm_recaptcha_config_secret_data
    }
    prospect_ingestion_oauth_parameter = {
      secret_suffix = "sm-prospect-ingestion-oauth-parameter"
      data          = var.sm_prospect_ingestion_oauth_parameter_secret_data
    }
  }

  gcs_bucket_entries = {
    exp_configs = {
      name_suffix = "gcs-exp-configs"
      config      = var.gcs_exp_configs
    }
    exp_templates = {
      name_suffix = "gcs-exp-templates"
      config      = var.gcs_exp_templates
    }
    prospect_configs = {
      name_suffix = "gcs-prospect-configs"
      config      = var.gcs_prospect_configs
    }
    prospect_dropzone = {
      name_suffix = "gcs-prospect-dropzone"
      config      = var.gcs_prospect_dropzone
    }
    privacy_configs = {
      name_suffix = "gcs-privacy-configs"
      config      = var.gcs_privacy_configs
    }
    privacy_consumer_archive = {
      name_suffix = "gcs-privacy-consumer-archive"
      config      = var.gcs_privacy_consumer_archive
    }
    aad_b2c_event_dropzone = {
      name_suffix = "gcs-aad-b2c-event-dropzone"
      config      = var.gcs_aadb2c_event_dropzone
    }
    aad_b2c_component_cdn = {
      name_suffix = "gcs-aad-b2c-component-cdn"
      config      = var.gcs_aad_b2c_component_cdn
    }
    aad_b2c_component_demo = {
      name_suffix = "gcs-aad-b2c-component-demo"
      config      = var.gcs_aad_b2c_component_demo
    }
    aad_b2c_component_account = {
      name_suffix = "gcs-aad-b2c-component-account"
      config      = var.gcs_aad_b2c_component_account
    }
    consumer_gamv2_demo_site = {
      name_suffix = "gcs-consumer-gamv2-demo-site"
      config      = var.gcs_consumer_gamv2_demo_site
    }
    processor_configs = {
      name_suffix = "gcs-processor-configs"
      config      = var.gcs_processor_configs
    }
  }

  # Global External Application LB - Marketing API Edge 
  marketing_api_edge_serverless_backend_services = {
    # For Temporary Validations Only
    frontend-get-consumer = {
      name            = "frontend-get-consumer"
      security_policy = module.ca_marketing_api_security.self_link
    }
    frontend-update-consumer = {
      name            = "frontend-update-consumer"
      security_policy = module.ca_marketing_api_security.self_link
    }
  }

  marketing_api_edge_path_matchers = {
    "api-paths" = {
      default_service = "frontend-get-consumer"
      rules = [
        # For Temporary Validations Only
        { paths = ["/v2/consumers"], service = "frontend-get-consumer" },
        { paths = ["/v2/consumers/update"], service = "frontend-update-consumer" }
      ]
    }
  }
  # Global External Application LB - Dedicated API Edge 
  dedicated_api_edge_serverless_backend_services = {
    aad-b2c-auth-consumer = {
      name            = "aad-b2c-authz-consumer"
      security_policy = module.ca_aad_b2c_api_security.self_link
    }
    aad-b2c-create-consumer = {
      name            = "aad-b2c-create-consumer"
      security_policy = module.ca_aad_b2c_api_security.self_link
    }
    aad-b2c-delete-consumer = {
      name            = "aad-b2c-delete-consumer"
      security_policy = module.ca_aad_b2c_api_security.self_link
    }
    aad-b2c-get-consumer = {
      name            = "aad-b2c-get-consumer"
      security_policy = module.ca_aad_b2c_api_security.self_link
    }
    aad-b2c-send-message = {
      name            = "aad-b2c-send-message"
      security_policy = module.ca_aad_b2c_api_security.self_link
    }
    aad-b2c-assess-consumer = {
      name            = "aad-b2c-assess-consumer"
      security_policy = module.ca_aad_b2c_api_security.self_link
    }
    aad-b2c-assess-fraud = {
      name            = "aad-b2c-assess-fraud"
      security_policy = module.ca_aad_b2c_api_security.self_link
    }
    aad-b2c-update-consumer = {
      name            = "aad-b2c-update-consumer"
      security_policy = module.ca_aad_b2c_api_security.self_link
    }
    internal-services = {
      name            = "internal-services"
      security_policy = module.internal_api_security.self_link
      iap_config = {
        enable = true
      }
    }
    privacy-show-my-data = {
      name            = "privacy-show-my-data"
      security_policy = module.privacy_api_security.self_link
    }
    privacy-unsubscribe = {
      name            = "privacy-unsubscribe"
      security_policy = module.privacy_api_security.self_link
    }
    privacy-forget-me = {
      name            = "privacy-forget-me"
      security_policy = module.privacy_api_security.self_link
    }
    prosp-dataflow-invoker = {
      name            = "prospect-dataflow-invoker"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-delete = {
      name            = "prospect-delete"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-email-processor = {
      name            = "prospect-email-processor"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-fetch = {
      name            = "prospect-fetch"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-forget-me = {
      name            = "prospect-forget-me"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-generic-processor = {
      name            = "prospect-generic-processor"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-google-processor = {
      name            = "prospect-google-processor"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-internal-processor = {
      name            = "prospect-internal-processor"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-latam-processor = {
      name            = "prospect-latam-processor"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-meta-processor = {
      name            = "prospect-meta-processor"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-meta-verify-token = {
      name            = "prospect-meta-verify-token"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-oauth-processor = {
      name            = "prospect-oauth-processor"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-show-my-data = {
      name            = "prospect-show-my-data"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-snapchat-generator = {
      name            = "prospect-snapchat-generator"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-snapchat-processor = {
      name            = "prospect-snapchat-processor"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-tiktok-dl-leads = {
      name            = "prospect-tiktok-dl-leads"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-tiktok-leads = {
      name            = "prospect-tiktok-leads"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-tiktok-processor = {
      name            = "prospect-tiktok-processor"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-tiktok-subscribe = {
      name            = "prospect-tiktok-subscribe"
      security_policy = module.prospect_api_security.self_link
    }
    prosp-unsubscribe-me = {
      name            = "prospect-unsubscribe-me"
      security_policy = module.prospect_api_security.self_link
    }
  }
  dedicated_api_edge_path_matchers = {
    "api-paths" = {
      default_service = "aad-b2c-auth-consumer"
      rules = [
        # { paths = ["/validate-consumer"], service = "aad-b2c-auth-consumer" },
        # { paths = ["/v2/consumers/create"], service = "aad-b2c-create-consumer" },
        # { paths = ["/v2/consumers/delete"], service = "aad-b2c-delete-consumer" },
        # { paths = ["/v2/consumers"], service = "aad-b2c-get-consumer" },
        # { paths = ["/v2/messages"], service = "aad-b2c-send-message" },
        # { paths = ["/assess-consumer/*"], service = "aad-b2c-assess-consumer" },
        # { paths = ["/v2/consumers/update"], service = "aad-b2c-update-consumer" },
        { paths = ["/static/*"], service = "gcs" },
        { paths = ["/privacy-show-my-data/*"], service = "privacy-show-my-data" },
        { paths = ["/privacy-unsubscribe/*"], service = "privacy-unsubscribe" },
        { paths = ["/privacy-forget-me/*"], service = "privacy-forget-me" },
        # { paths = ["/v2/prospects"], service = "prosp-delete" },
        # { paths = ["/v2/*/prospects/*"], service = "prosp-delete" },
        # { paths = ["/v2/prospects"], service = "prosp-fetch" },
        # { paths = ["/v2/*/prospects/*"], service = "prosp-fetch" },
        # { paths = ["/prosp-dataflow-invoker/*"], service = "prosp-dataflow-invoker" },
        # { paths = ["/prosp-email-processor/*"], service = "prosp-email-processor" },
        # { paths = ["/v2/delete-my-data"], service = "prosp-forget-me" },
        # { paths = ["/prosp-generic-processor/*"], service = "prosp-generic-processor" },
        # { paths = ["/v2/processors/google"], service = "prosp-google-processor" },
        # { paths = ["/prosp-internal-processor/*"], service = "prosp-internal-processor" },
        # { paths = ["/prosp-latam-processor/*"], service = "prosp-latam-processor" },
        # { paths = ["/prosp-meta-processor/*"], service = "prosp-meta-processor" },
        # { paths = ["/prosp-meta-verify-token/*"], service = "prosp-meta-verify-token" },
        # { paths = ["/prosp-oauth-processor/*"], service = "prosp-oauth-processor" },
        # { paths = ["/v2/show-my-data"], service = "prosp-show-my-data" },
        # { paths = ["/prosp-snapchat-generator/*"], service = "prosp-snapchat-generator" },
        # { paths = ["/prosp-snapchat-processor/*"], service = "prosp-snapchat-processor" },
        # { paths = ["/prosp-tiktok-dl-leads/*"], service = "prosp-tiktok-dl-leads" },
        # { paths = ["/prosp-tiktok-leads/*"], service = "prosp-tiktok-leads" },
        # { paths = ["/prosp-tiktok-processor/*"], service = "prosp-tiktok-processor" },
        # { paths = ["/prosp-tiktok-subscribe/*"], service = "prosp-tiktok-subscribe" },
        # { paths = ["/v2/unsubscribe"], service = "prosp-unsubscribe-me" }
      ]
    }
    "aadb2c-services-paths" = {
      default_service = "aad-b2c-auth-consumer"
      route_rules = [
        {
          priority = 1
          service  = "aad-b2c-assess-fraud"
          match_rules = [
            {
              full_path_match = "/v2/validate-fraud"
              header_matches = [
                { header_name = ":method", exact_match = "POST" }
              ]
            }
          ]
        },
        {
          priority = 2
          service  = "aad-b2c-auth-consumer"
          match_rules = [
            {
              prefix_match = "/validate-consumer"
            }
          ]
        },
        {
          priority = 3
          service  = "aad-b2c-create-consumer"
          match_rules = [
            {
              prefix_match = "/v2/consumers/create"
            }
          ]
        },
        {
          priority = 4
          service  = "aad-b2c-delete-consumer"
          match_rules = [
            {
              prefix_match = "/v2/consumers/delete"
            }
          ]
        },
        {
          priority = 5
          service  = "aad-b2c-get-consumer"
          match_rules = [
            {
              prefix_match = "/v2/consumers"
            }
          ]
        },
        {
          priority = 6
          service  = "aad-b2c-send-message"
          match_rules = [
            {
              prefix_match = "/v2/messages"
            }
          ]
        },
        {
          priority = 7
          service  = "aad-b2c-assess-consumer"
          match_rules = [
            {
              prefix_match = "/assess-consumer/*"
            }
          ]
        },
        {
          priority = 8
          service  = "aad-b2c-update-consumer"
          match_rules = [
            {
              prefix_match = "/v2/consumers/update"
            }
          ]
        }
      ]
    },
    "internal-services-paths" = {
      default_service = "internal-services"
      route_rules = [
        {
          priority = 1
          service  = "internal-services"
          match_rules = [
            {
              full_path_match = "/v2/consumers"
              header_matches = [
                { header_name = ":method", exact_match = "POST" }
              ]
            }
          ]
        }
      ]
    },
    # Path matcher dedicated to prospects, using route_rules
    "prospect-services-paths" = {
      default_service = "prosp-fetch"

      route_rules = [
        {
          priority = 1
          service  = "prosp-delete"
          match_rules = [
            {
              full_path_match = "/v2/prospects"
              header_matches = [
                { header_name = ":method", exact_match = "DELETE" }
              ]
            }
          ]
        },
        {
          priority = 2
          service  = "prosp-fetch"
          match_rules = [
            {
              full_path_match = "/v2/prospects"
              header_matches = [
                { header_name = ":method", exact_match = "GET" }
              ]
            }
          ]
        },
        {
          priority = 3
          service  = "prosp-dataflow-invoker"
          match_rules = [
            {
              prefix_match = "/prosp-dataflow-invoker/"
            }
          ]
        },
        {
          priority = 4
          service  = "prosp-email-processor"
          match_rules = [
            {
              prefix_match = "/prosp-email-processor/"
            }
          ]
        },
        {
          priority = 5
          service  = "prosp-forget-me"
          match_rules = [
            {
              full_path_match = "/v2/delete-my-data"
            }
          ]
        },
        {
          priority = 6
          service  = "prosp-generic-processor"
          match_rules = [
            {
              prefix_match = "/prosp-generic-processor/"
            }
          ]
        },
        {
          priority = 7
          service  = "prosp-google-processor"
          match_rules = [
            {
              full_path_match = "/v2/processors/google"
            }
          ]
        },
        {
          priority = 8
          service  = "prosp-internal-processor"
          match_rules = [
            {
              prefix_match = "/prosp-internal-processor/"
            }
          ]
        },
        {
          priority = 9
          service  = "prosp-latam-processor"
          match_rules = [
            {
              full_path_match = "/v2/processors/latam"
            }
          ]
        },
        {
          priority = 10
          service  = "prosp-meta-processor"
          match_rules = [
            {
              prefix_match = "/prosp-meta-processor/"
            }
          ]
        },
        {
          priority = 11
          service  = "prosp-meta-verify-token"
          match_rules = [
            {
              full_path_match = "/v2/meta-verify-token"
            }
          ]
        },
        {
          priority = 12
          service  = "prosp-oauth-processor"
          match_rules = [
            {
              prefix_match = "/prosp-oauth-processor/"
            }
          ]
        },
        {
          priority = 13
          service  = "prosp-show-my-data"
          match_rules = [
            {
              full_path_match = "/v2/show-my-data"
            }
          ]
        },
        {
          priority = 14
          service  = "prosp-snapchat-generator"
          match_rules = [
            {
              prefix_match = "/prosp-snapchat-generator/"
            }
          ]
        },
        {
          priority = 15
          service  = "prosp-snapchat-processor"
          match_rules = [
            {
              prefix_match = "/prosp-snapchat-processor/"
            }
          ]
        },
        {
          priority = 16
          service  = "prosp-tiktok-dl-leads"
          match_rules = [
            {
              prefix_match = "/prosp-tiktok-dl-leads/"
            }
          ]
        },
        {
          priority = 17
          service  = "prosp-tiktok-leads"
          match_rules = [
            {
              full_path_match = "/v2/processors/tiktok/leads"
            }
          ]
        },
        {
          priority = 18
          service  = "prosp-tiktok-processor"
          match_rules = [
            {
              full_path_match = "/v2/processors/tiktok"
            }
          ]
        },
        {
          priority = 19
          service  = "prosp-tiktok-subscribe"
          match_rules = [
            {
              full_path_match = "/v2/processors/tiktok/subscribe"
            }
          ]
        },
        {
          priority = 20
          service  = "prosp-unsubscribe-me"
          match_rules = [
            {
              full_path_match = "/v2/unsubscribe"
            }
          ]
        }
        ,
        {
          priority = 21
          service  = "prosp-delete"
          match_rules = [
            {
              path_template_match = "/v2/{koRegion=*}/prospects/{hashedKocid=*}"
              header_matches = [
                { header_name = ":method", exact_match = "DELETE" }
              ]
            }
          ]
        },
        {
          priority = 22
          service  = "prosp-fetch"
          match_rules = [
            {
              path_template_match = "/v2/{koRegion=*}/prospects/{hashedKocid=*}"
              header_matches = [
                { header_name = ":method", exact_match = "GET" }
              ]
            }
          ]
        }
      ]
    }
  }
}

data "google_compute_network" "network" {
  project = var.network_project_id
  name    = var.network
}

data "google_compute_subnetwork" "ilb_subnet_primary" {
  count   = contains(["alpha", "beta", "gamma", "prod"], lower(var.environment)) ? 1 : 0
  name    = var.ilb_subnet_primary
  project = var.network_project_id
  region  = local.region["PRIMARY"]
}

data "google_compute_subnetwork" "psc_subnet_primary" {
  count   = contains(["alpha", "beta", "gamma", "prod"], lower(var.environment)) ? 1 : 0
  name    = var.psc_subnet_primary
  project = var.network_project_id
  region  = local.region["PRIMARY"]
}

data "google_compute_subnetwork" "ilb_subnet_secondary" {
  count   = contains(["gamma", "prod"], lower(var.environment)) ? 1 : 0
  name    = var.ilb_subnet_secondary
  project = var.network_project_id
  region  = local.region["SECONDARY"]
}

data "google_compute_subnetwork" "psc_subnet_secondary" {
  count   = contains(["gamma", "prod"], lower(var.environment)) ? 1 : 0
  name    = var.psc_subnet_secondary
  project = var.network_project_id
  region  = local.region["SECONDARY"]
}

module "secret_manager" {
  for_each   = local.secret_manager_entries
  source     = local.secret_manager_module_source
  project_id = var.project_id
  secrets = {
    "${local.resource_name_prefix_global}-${each.value.secret_suffix}" = {
      deletion_protection = false
      versions = {
        default = {
          data = each.value.data
        }
      }
    }
  }
}

module "gcs_buckets" {
  for_each                 = local.gcs_bucket_entries
  source                   = local.gcs_bucket_module_source
  project_id               = var.project_id
  name                     = "${local.resource_name_prefix_global}-${each.value.name_suffix}"
  location                 = each.value.config.location
  public_access_prevention = each.value.config.public_access_prevention
  bucket_policy_only       = each.value.config.uniform_bucket_level_access
  force_destroy            = each.value.config.force_destroy
}

# Firestore - Privacy
module "fs_main_database" {
  source     = local.firestore_module_source
  project_id = var.project_id
  database = {
    name                              = "${local.resource_name_prefix_global}-fs-main-database"
    location_id                       = var.fs_main_database.location
    type                              = var.fs_main_database.database_type
    concurrency_mode                  = var.fs_main_database.concurrency_mode
    app_engine_integration_mode       = var.fs_main_database.app_engine_integration_mode
    point_in_time_recovery_enablement = var.fs_main_database.point_in_time_recovery_enablement
    delete_protection_state           = var.fs_main_database.delete_protection_state
    deletion_policy                   = var.fs_main_database.deletion_policy
    kms_key_name                      = var.fs_main_database.kms_key_name
  }
}

module "spn_main_instance" {
  source     = local.spanner_instance_module_source
  project_id = var.project_id
  instance = {
    name         = local.spanner_instance_name
    display_name = "${local.resource_name_prefix_global}-spn"
    config = {
      name = var.spn_main_instance.instance_config
    }
    num_nodes        = var.spn_main_instance.num_nodes
    processing_units = var.spn_main_instance.processing_units
    force_destroy    = var.spn_main_instance.force_destroy
    autoscaling = var.spn_main_instance.enable_autoscaling ? {
      limits = {
        min_processing_units = var.spn_main_instance.min_processing_units
        max_processing_units = var.spn_main_instance.max_processing_units
      }
      targets = {
        high_priority_cpu_utilization_percent = var.spn_main_instance.high_priority_cpu_utilization_percent
        storage_utilization_percent           = var.spn_main_instance.storage_utilization_percent
      }
    } : null
  }
  databases = {
    (local.spanner_database_name) = {
      version_retention_period = var.spn_main_instance_consumer_db.version_retention_period
      ddl                      = var.spn_main_instance_consumer_db.ddl
      database_dialect         = var.spn_main_instance_consumer_db.database_dialect
      enable_drop_protection   = var.spn_main_instance_consumer_db.enable_drop_protection
      kms_key_name             = try(var.spn_main_instance_consumer_db.encryption_config.kms_key_name, null)
    }
  }
}

module "spn_main_instance_consumer_db_backup" {
  source                      = local.spanner_backup_module_source
  project_id                  = var.project_id
  instance_name               = local.spanner_instance_name
  database_name               = local.spanner_database_name
  backup_schedule_name        = "${local.resource_name_prefix_global}-spn-main-instance-bkp-schedule"
  retention_duration          = var.spn_main_instance_consumer_db_backup.retention_duration
  cron_spec_text              = var.spn_main_instance_consumer_db_backup.cron_spec_text
  use_full_backup_spec        = coalesce(var.spn_main_instance_consumer_db_backup.use_full_backup_spec, false)
  use_incremental_backup_spec = coalesce(var.spn_main_instance_consumer_db_backup.use_incremental_backup_spec, false)
}

# PSC NEG Northbound
# module "psc_neg_northbound_frontend" {
#   source                = "${local.modules_source_repo}/region_network_endpoint_group"
#   project_id            = var.project_id
#   region                = local.region["PRIMARY"]
#   name                  = "${local.resource_name_prefix_global}-psc-neg-nb-frontend"
#   network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
#   psc_target_service    = "" # To be added from the output of Apigee Instance (Service Attachment will be created automatically)
#   network               = module.c4p_network_main.network_name
#   subnetwork            = data.google_compute_subnetwork.ilb_subnet_primary[0].id
# }

# [ Marketing API Edge START ]
# Reserved External IP - ip-marketing-api-edge
module "ip_marketing_api_edge" {
  source     = local.net_address_module_source
  project_id = var.mgmt_project_id
  global_addresses = {
    "${local.resource_name_prefix_global}-ip-marketing-api-edge" = {}
  }
}

# Cloud Armor - ca-marketing-api-security
module "ca_marketing_api_security" {
  source           = local.cloud_armor_module_source
  project_id       = var.project_id
  name             = "${local.resource_name_prefix_global}-ca-marketing-api-security"
}

module "certificate_manager_marketing_api_edge" {
  source     = local.certificate_manager_module_source
  project_id = var.mgmt_project_id
  dns_authorizations = {
    "${local.resource_name_prefix_global}-da-wildcard" = {
      domain = var.wildcard_domain
      type   = "PER_PROJECT_RECORD"
    }
  }
  certificates = {
    "${local.resource_name_prefix_global}-gmc-wildcard" = {
      managed = {
        domains            = ["*.${var.wildcard_domain}"]
        dns_authorizations = ["${local.resource_name_prefix_global}-da-wildcard"]
      }
    }
  }
  map = {
    name = "${local.resource_name_prefix_global}-cm-marketing-api-edge"
    entries = {
      "cme-wildcard" = {
        certificates = ["${local.resource_name_prefix_global}-gmc-wildcard"]
        hostname     = "*.${var.wildcard_domain}"
      }
    }
  }
}

# Global External Application Load Balancer - lb-marketing-api-edge
module "lb_marketing_api_edge" {
  count                 = var.create_lb_marketing_api_edge ? 1 : 0
  source                = local.global_external_application_load_balancer_module_source
  project_id            = var.mgmt_project_id
  fabric_version        = var.cloud_foundation_fabric_version
  lb_name               = "${local.resource_name_prefix_global}-lb-marketing-api-edge"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  https_redirect        = true
  ssl                   = true
  certificate_map       = "//certificatemanager.googleapis.com/${module.certificate_manager_marketing_api_edge.map_id}"
  ip_address            = module.ip_marketing_api_edge.global_addresses["${local.resource_name_prefix_global}-ip-marketing-api-edge"].id
  default_service_key   = local.marketing_api_edge_path_matchers["api-paths"].default_service

  backends = {
    for backend_key, svc in local.marketing_api_edge_serverless_backend_services :
    backend_key => {
      project         = var.project_id
      protocol        = "HTTP"
      enable_cdn      = false
      security_policy = svc.security_policy
      log_config      = { enable = true }
      serverless_neg_backends = [
        {
          region  = local.region["PRIMARY"]
          type    = "cloud-run"
          service = { name = format("%s-run-%s", local.resource_name_prefix_global, svc.name) }
        }
      ]
    }
  }
  path_matchers = local.marketing_api_edge_path_matchers
  host_rules = [
    {
      hosts        = ["*"]
      path_matcher = "api-paths"
    }
  ]
}
# [ Marketing API Edge END ]

# Cloud Armor - ca-message-api-security
module "ca_message_api_security" {
  source           = local.cloud_armor_module_source
  project_id       = var.project_id
  name             = "${local.resource_name_prefix_global}-ca-message-api-security"
}

# Cloud Armor - ca-internal-api-security
module "internal_api_security" {
  source           = local.cloud_armor_module_source
  project_id       = var.project_id
  name             = "${local.resource_name_prefix_global}-internal-api-security"
}

# Cloud Armor - ca-privacy-api-security
module "privacy_api_security" {
  source           = local.cloud_armor_module_source
  project_id       = var.project_id
  name             = "${local.resource_name_prefix_global}-privacy-api-security"
}

# Cloud Armor - ca-prospect-api-security
module "prospect_api_security" {
  source           = local.cloud_armor_module_source
  project_id       = var.project_id
  name             = "${local.resource_name_prefix_global}-prospect-api-security"
}

# [ Dedicated API Edge START ]
# Reserved IP - dedicated-api-edge
module "ip_dedicated_api_edge" {
  source     = local.net_address_module_source
  project_id = var.project_id
  global_addresses = {
    "${local.resource_name_prefix_global}-ip-dedicated-api-edge" = {}
  }
}

# Cloud Armor - ca-aad-b2c-api-security
module "ca_aad_b2c_api_security" {
  source           = local.cloud_armor_module_source
  project_id       = var.project_id
  name             = "${local.resource_name_prefix_global}-ca-aad-b2c-api-security"
}

module "certificate_manager_dedicated_api_edge" {
  source     = local.certificate_manager_module_source
  project_id = var.project_id
  dns_authorizations = {
    "${local.resource_name_prefix_global}-da-wildcard" = {
      domain = var.wildcard_domain
      type   = "PER_PROJECT_RECORD"
    }
    "${local.resource_name_prefix_global}-da-prospect" = {
      domain = var.prospect_domain
      type   = "FIXED_RECORD"
    }
  }
  certificates = {
    "${local.resource_name_prefix_global}-gmc-wildcard" = {
      managed = {
        domains            = ["*.${var.wildcard_domain}"]
        dns_authorizations = ["${local.resource_name_prefix_global}-da-wildcard"]
      }
    }
    "${local.resource_name_prefix_global}-gmc-prospect" = {
      managed = {
        domains            = ["*.${var.prospect_domain}"]
        dns_authorizations = ["${local.resource_name_prefix_global}-da-prospect"]
      }
    }
  }
  map = {
    name = "${local.resource_name_prefix_global}-cm-dedicated-api-edge"
    entries = {
      "cme-wildcard" = {
        certificates = ["${local.resource_name_prefix_global}-gmc-wildcard"]
        hostname     = "*.${var.wildcard_domain}"
      }
      "cme-prospect" = {
        certificates = ["${local.resource_name_prefix_global}-gmc-prospect"]
        hostname     = "*.${var.prospect_domain}"
      }
    }
  }
}

# Global External Application Load Balancer - dedicated-api-edge
module "lb_dedicated_api_edge" {
  count                 = var.create_lb_dedicated_api_edge ? 1 : 0
  source                = local.global_external_application_load_balancer_module_source
  project_id            = var.project_id
  fabric_version        = var.cloud_foundation_fabric_version
  lb_name               = "${local.resource_name_prefix_global}-lb-dedicated-api-edge"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  https_redirect        = true
  ssl                   = true
  certificate_map       = "//certificatemanager.googleapis.com/${module.certificate_manager_dedicated_api_edge.map_id}"
  ip_address            = module.ip_dedicated_api_edge.global_addresses["${local.resource_name_prefix_global}-ip-dedicated-api-edge"].id
  default_service_key   = local.dedicated_api_edge_path_matchers["api-paths"].default_service

  backends = {
    for backend_key, svc in local.dedicated_api_edge_serverless_backend_services :
    backend_key => {
      project         = var.project_id
      protocol        = "HTTP"
      enable_cdn      = false
      security_policy = svc.security_policy
      log_config      = { enable = true }
      iap_config      = lookup(svc, "iap_config", null)
      serverless_neg_backends = [
        {
          region  = local.region["PRIMARY"]
          type    = "cloud-run"
          service = { name = format("%s-run-%s", local.resource_name_prefix_global, svc.name) }
        }
      ]
    }
  }
  backend_buckets = {
    gcs = {
      bucket_name = module.gcs_buckets["exp_configs"].name
      enable_cdn  = true
      cdn_policy = {
        cache_mode  = "CACHE_ALL_STATIC"
        default_ttl = 3600
        max_ttl     = 86400
      }
    }
  }
  path_matchers = local.dedicated_api_edge_path_matchers
  host_rules = [
    {
      hosts        = ["*.${var.prospect_domain}"]
      path_matcher = "prospect-services-paths"
    },
    {
      hosts        = ["${var.internal_services_hostname}.${var.wildcard_domain}"]
      path_matcher = "internal-services-paths"
    },
    {
      hosts        = ["${var.aadb2c_services_hostname}.${var.wildcard_domain}"]
      path_matcher = "aadb2c-services-paths"
    },
    {
      hosts        = ["*"]
      path_matcher = "api-paths"
    }
  ]
}
# [ Dedicated API Edge END ]

# Internal Address
module "ip_marketing_ilb_primary" {
  count      = contains(["alpha", "beta", "gamma", "prod"], lower(var.environment)) ? 1 : 0
  source     = local.net_address_module_source
  project_id = var.project_id
  internal_addresses = {
    "${local.resource_name_prefix_primary}-ip-marketing" = {
      region     = local.region["PRIMARY"]
      address    = "10.0.8.150"
      subnetwork = data.google_compute_subnetwork.ilb_subnet_primary[0].self_link
    }
  }
}

module "ip_marketing_ilb_secondary" {
  count      = contains(["gamma", "prod"], lower(var.environment)) ? 1 : 0
  source     = local.net_address_module_source
  project_id = var.project_id
  internal_addresses = {
    "${local.resource_name_prefix_secondary}-ip-marketing" = {
      region     = local.region["SECONDARY"]
      address    = "10.0.8.250"
      subnetwork = data.google_compute_subnetwork.ilb_subnet_secondary[0].self_link
    }
  }
}

# [PRIMARY START]

# Valkey Memorystore
module "vkey_main_primary" {
  count                         = local.deploy_primary ? 1 : 0
  source                        = local.memorystore_valkey_module_source
  project_id                    = var.project_id
  network_project               = var.network_project_id
  instance_id                   = "${local.resource_name_prefix_primary}-vkey-main"
  location                      = local.region["PRIMARY"]
  network                       = data.google_compute_network.network.name
  zone_distribution_config_zone = local.zone["PRIMARY"]
  authorization_mode            = var.vkey_main_primary.authorization_mode
  engine_version                = var.vkey_main_primary.engine_version
  shard_count                   = var.vkey_main_primary.shard_count
  zone_distribution_config_mode = var.vkey_main_primary.zone_distribution_config_mode
  deletion_protection_enabled   = var.vkey_main_primary.deletion_protection_enabled
}

# [ Internal Application LB - Marketing START ]
# Internal Application LB - Marketing (primary)
module "lb_marketing_primary" {
  count      = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  source     = local.internal_application_load_balancer_module_source
  project_id = var.project_id
  region     = local.region["PRIMARY"]
  name       = "${local.resource_name_prefix_primary}-lb-marketing"
  address    = module.ip_marketing_ilb_primary[0].internal_addresses["${local.resource_name_prefix_primary}-ip-marketing"].address
  protocol   = "HTTP"
  ports      = ["80"]

  backend_service_configs = {
    frontend-update-consumer = {
      health_checks = []
      backends      = [{ group = "frontend-update-consumer" }]
    }
    frontend-get-consumer = {
      health_checks = []
      backends      = [{ group = "frontend-get-consumer" }]
    }
    message-event-processor = {
      health_checks = []
      backends      = [{ group = "message-event-processor" }]
    }
    enrichment-get-data = {
      health_checks = []
      backends      = [{ group = "enrichment-get-data" }]
    }
    enrichment-put-data = {
      health_checks = []
      backends      = [{ group = "enrichment-put-data" }]
    }
  }

  health_check_configs = {}

  neg_configs = {
    frontend-update-consumer = {
      cloudrun = {
        region = local.region["PRIMARY"]
        target_service = {
          name = format("%s-run-frontend-update-consumer", local.resource_name_prefix_primary)
        }
      }
    }
    frontend-get-consumer = {
      cloudrun = {
        region = local.region["PRIMARY"]
        target_service = {
          name = format("%s-run-frontend-get-consumer", local.resource_name_prefix_primary)
        }
      }
    }
    message-event-processor = {
      cloudrun = {
        region = local.region["PRIMARY"]
        target_service = {
          name = format("%s-run-message-event-processor", local.resource_name_prefix_primary)
        }
      }
    }
    enrichment-get-data = {
      cloudrun = {
        region = local.region["PRIMARY"]
        target_service = {
          name = format("%s-run-enrichment-get-data", local.resource_name_prefix_primary)
        }
      }
    }
    enrichment-put-data = {
      cloudrun = {
        region = local.region["PRIMARY"]
        target_service = {
          name = format("%s-run-enrichment-put-data", local.resource_name_prefix_primary)
        }
      }
    }
  }

  vpc_config = {
    network    = data.google_compute_network.network.self_link
    subnetwork = data.google_compute_subnetwork.ilb_subnet_primary[0].self_link
  }

  urlmap_config = {
    default_service = "frontend-get-consumer"
    host_rules = [{
      hosts        = ["*"]
      path_matcher = "api-paths"
    }]
    path_matchers = {
      api-paths = {
        default_service = "frontend-get-consumer"
        path_rules = [
          { paths = ["/v2/consumers/update"], service = "frontend-update-consumer" },
          { paths = ["/v2/consumers"], service = "frontend-get-consumer" },
          { paths = ["/message-event-processor/*"], service = "message-event-processor" },
          { paths = ["/enrichment-get-data/*"], service = "enrichment-get-data" },
          { paths = ["/enrichment-put-data/*"], service = "enrichment-put-data" }
        ]
      }
    }
  }

  service_attachment = {
    nat_subnets           = [data.google_compute_subnetwork.psc_subnet_primary[0].id]
    automatic_connection  = true
    enable_proxy_protocol = false
  }
}

# [PRIMARY END]

# [SECONDARY START]
module "vkey_main_secondary" {
  source                        = local.memorystore_valkey_module_source
  count                         = local.deploy_secondary ? 1 : 0
  project_id                    = var.project_id
  network_project               = var.network_project_id
  instance_id                   = "${local.resource_name_prefix_secondary}-vkey-main"
  location                      = local.region["SECONDARY"]
  network                       = data.google_compute_network.network.name
  zone_distribution_config_zone = local.zone["SECONDARY"]
  authorization_mode            = var.vkey_main_secondary.authorization_mode
  engine_version                = var.vkey_main_secondary.engine_version
  shard_count                   = var.vkey_main_secondary.shard_count
  zone_distribution_config_mode = var.vkey_main_secondary.zone_distribution_config_mode
  deletion_protection_enabled   = var.vkey_main_secondary.deletion_protection_enabled
}
# [ Internal Application LB - Marketing START ]
# Internal Application LB - Marketing (secondary)
module "lb_marketing_secondary" {
  count      = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  source     = local.internal_application_load_balancer_module_source
  project_id = var.project_id
  region     = local.region["SECONDARY"]
  name       = "${local.resource_name_prefix_secondary}-lb-marketing"
  address    = module.ip_marketing_ilb_secondary[0].internal_addresses["${local.resource_name_prefix_secondary}-ip-marketing"].address
  protocol   = "HTTP"
  ports      = ["80"]

  backend_service_configs = {
    frontend-update-consumer = { health_checks = [], backends = [{ group = "frontend-update-consumer" }] }
    frontend-get-consumer    = { health_checks = [], backends = [{ group = "frontend-get-consumer" }] }
    message-event-processor  = { health_checks = [], backends = [{ group = "message-event-processor" }] }
    enrichment-get-data      = { health_checks = [], backends = [{ group = "enrichment-get-data" }] }
    enrichment-put-data      = { health_checks = [], backends = [{ group = "enrichment-put-data" }] }
  }

  health_check_configs = {}

  neg_configs = {
    frontend-update-consumer = { cloudrun = { region = local.region["SECONDARY"], target_service = { name = format("%s-run-frontend-update-consumer", local.resource_name_prefix_secondary) } } }
    frontend-get-consumer    = { cloudrun = { region = local.region["SECONDARY"], target_service = { name = format("%s-run-frontend-get-consumer", local.resource_name_prefix_secondary) } } }
    message-event-processor  = { cloudrun = { region = local.region["SECONDARY"], target_service = { name = format("%s-run-message-event-processor", local.resource_name_prefix_secondary) } } }
    enrichment-get-data      = { cloudrun = { region = local.region["SECONDARY"], target_service = { name = format("%s-run-enrichment-get-data", local.resource_name_prefix_secondary) } } }
    enrichment-put-data      = { cloudrun = { region = local.region["SECONDARY"], target_service = { name = format("%s-run-enrichment-put-data", local.resource_name_prefix_secondary) } } }
  }

  vpc_config = {
    network    = data.google_compute_network.network.self_link
    subnetwork = data.google_compute_subnetwork.ilb_subnet_secondary[0].self_link
  }

  urlmap_config = {
    default_service = "frontend-get-consumer"
    host_rules      = [{ hosts = ["*"], path_matcher = "api-paths" }]
    path_matchers = {
      api-paths = {
        default_service = "frontend-get-consumer"
        path_rules = [
          { paths = ["/update-consumer/*"], service = "frontend-update-consumer" },
          { paths = ["/get-consumer/*"], service = "frontend-get-consumer" },
          { paths = ["/message-event-processor/*"], service = "message-event-processor" },
          { paths = ["/enrichment-get-data/*"], service = "enrichment-get-data" },
          { paths = ["/enrichment-put-data/*"], service = "enrichment-put-data" }
        ]
      }
    }
  }

  service_attachment = {
    nat_subnets           = [data.google_compute_subnetwork.psc_subnet_secondary[0].id]
    automatic_connection  = true
    enable_proxy_protocol = false
  }
}

# [SECONDARY END]

# [Core Infrastructure END]

# To be deleted

# module "managed_cert_wildcard_dedicated_api_edge" {
#   source                   = "${local.modules_source_repo}/google_managed_certificate"
#   project_id               = var.project_id
#   certificate_name         = "${local.resource_name_prefix_global}-gmc-wildcard"
#   dns_authorization_name   = "${local.resource_name_prefix_global}-da-wildcard"
#   dns_authorization_domain = "alpha.global.gcds.coke.com"
#   domain                   = "*.alpha.global.gcds.coke.com"
# }

# # Google Managed Certificate with DNS Authorization
# module "managed_cert_prospect_dedicated_api_edge" {
#   source                   = "${local.modules_source_repo}/google_managed_certificate"
#   project_id               = var.project_id
#   certificate_name         = "${local.resource_name_prefix_global}-gmc-prospect"
#   dns_authorization_name   = "${local.resource_name_prefix_global}-da-prospect"
#   dns_authorization_domain = "prospect.alpha.global.gcds.coke.com"
#   domain                   = "*.prospect.alpha.global.gcds.coke.com"
# }


# # Google Managed Certificate with DNS Authorization
# module "managed_cert_internal" {
#   source                   = "${local.modules_source_repo}/google_managed_certificate"
#   project_id               = var.project_id
#   certificate_name         = "${local.resource_name_prefix_global}-gmc-internal"
#   dns_authorization_name   = "${local.resource_name_prefix_global}-da-internal"
#   dns_authorization_domain = "internal.alpha.global.gcds.coke.com"
#   domain                   = "*.internal.alpha.global.gcds.coke.com"
# }

# # Google Managed Certificate with DNS Authorization
# module "managed_cert_privacy" {
#   source                   = "${local.modules_source_repo}/google_managed_certificate"
#   project_id               = var.project_id
#   certificate_name         = "${local.resource_name_prefix_global}-gmc-privacy"
#   dns_authorization_name   = "${local.resource_name_prefix_global}-da-privacy"
#   dns_authorization_domain = "privacy.alpha.global.gcds.coke.com"
#   domain                   = "*.privacy.alpha.global.gcds.coke.com"
# }

# # Google Managed Certificate with DNS Authorization
# module "managed_cert_conversion_prospect" {
#   source                   = "${local.modules_source_repo}/google_managed_certificate"
#   project_id               = var.project_id
#   certificate_name         = "${local.resource_name_prefix_global}-gmc-conversion-prospect"
#   dns_authorization_name   = "${local.resource_name_prefix_global}-da-conversion-prospect"
#   dns_authorization_domain = "conversion.prospect.alpha.global.gcds.coke.com"
#   domain                   = "*.conversion.prospect.alpha.global.gcds.coke.com"
# }

# # Google Managed Certificate with DNS Authorization
# module "managed_cert_ingestion_prospect" {
#   source                   = "${local.modules_source_repo}/google_managed_certificate"
#   project_id               = var.project_id
#   certificate_name         = "${local.resource_name_prefix_global}-gmc-ingestion-prospect"
#   dns_authorization_name   = "${local.resource_name_prefix_global}-da-ingestion-prospect"
#   dns_authorization_domain = "ingestion.prospect.alpha.global.gcds.coke.com"
#   domain                   = "*.ingestion.prospect.alpha.global.gcds.coke.com"
# }

# # Google Managed Certificate with DNS Authorization
# module "managed_cert_privacy_prospect" {
#   source                   = "${local.modules_source_repo}/google_managed_certificate"
#   project_id               = var.project_id
#   certificate_name         = "${local.resource_name_prefix_global}-gmc-privacy-prospect"
#   dns_authorization_name   = "${local.resource_name_prefix_global}-da-privacy-prospect"
#   dns_authorization_domain = "privacy.prospect.alpha.global.gcds.coke.com"
#   domain                   = "*.privacy.prospect.alpha.global.gcds.coke.com"
# }

# # Google Managed Certificate with DNS Authorization
# module "managed_cert_services_prospect" {
#   source                   = "${local.modules_source_repo}/google_managed_certificate"
#   project_id               = var.project_id
#   certificate_name         = "${local.resource_name_prefix_global}-gmc-services-prospect"
#   dns_authorization_name   = "${local.resource_name_prefix_global}-da-services-prospect"
#   dns_authorization_domain = "services.prospect.alpha.global.gcds.coke.com"
#   domain                   = "*.services.prospect.alpha.global.gcds.coke.com"
# }

# # Google Managed Certificate with DNS Authorization
# module "managed_cert_frontend" {
#   source                   = "${local.modules_source_repo}/google_managed_certificate"
#   project_id               = var.mgmt_project_id
#   certificate_name         = "${local.resource_name_prefix_global}-gmc-frontend"
#   dns_authorization_name   = "${local.resource_name_prefix_global}-da-frontend"
#   dns_authorization_domain = "frontend.alpha.global.gcds.coke.com"
#   domain                   = "*.frontend.alpha.global.gcds.coke.com"
# }

# # Google Managed Certificate with DNS Authorization
# module "managed_cert_messages" {
#   source                   = "${local.modules_source_repo}/google_managed_certificate"
#   project_id               = var.mgmt_project_id
#   certificate_name         = "${local.resource_name_prefix_global}-gmc-messages"
#   dns_authorization_name   = "${local.resource_name_prefix_global}-da-messages"
#   dns_authorization_domain = "messages.alpha.global.gcds.coke.com"
#   domain                   = "*.messages.alpha.global.gcds.coke.com"
# }

# # Google Managed Certificate with DNS Authorization
# module "managed_cert_enrichment" {
#   source                   = "${local.modules_source_repo}/google_managed_certificate"
#   project_id               = var.mgmt_project_id
#   certificate_name         = "${local.resource_name_prefix_global}-gmc-enrichment"
#   dns_authorization_name   = "${local.resource_name_prefix_global}-da-enrichment"
#   dns_authorization_domain = "enrichment.alpha.global.gcds.coke.com"
#   domain                   = "*.enrichment.alpha.global.gcds.coke.com"
# }
