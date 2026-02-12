locals {
  region_by_geo_type = {
    "PRODUCT" = {
      "PRIMARY"   = "us-central1"
      "SECONDARY" = "us-east1"
    }
  }

  zone_by_geo_type = {
    "PRODUCT" = {
      "PRIMARY"   = "us-central1-a"
      "SECONDARY" = "us-east1-b"
    }
  }

  region = local.region_by_geo_type[upper(var.geo)]
  zone   = local.zone_by_geo_type[upper(var.geo)]

  # Whether to create primary/secondary region specific resources. There will be no secondary regions in alpha and beta env
  deploy_primary   = contains(["gamma", "prod"], lower(var.environment)) ? var.deploy_primary : true
  deploy_secondary = contains(["gamma", "prod"], lower(var.environment)) ? var.deploy_secondary : false
  spanner_instance_name = "${local.resource_name_prefix_global}-spn-main-instance"
  spanner_database_name = var.spn_main_instance_consumer_db.name

  # For gamma and prod, assign regional prefixes. For other environments, keep prefixes empty.
  regional_prefixes              = contains(["gamma", "prod"], lower(var.environment)) ? ["-pri", "-sec"] : ["", ""]
  resource_name_prefix_primary   = format("%s-%s%s", var.environment, var.app_code, local.regional_prefixes[0])
  resource_name_prefix_secondary = format("%s-%s%s", var.environment, var.app_code, local.regional_prefixes[1])
  resource_name_prefix_global    = format("%s-%s", var.environment, var.app_code)
  modules_source_repo            = "git::https://github.com/The-Coca-Cola-Company/consumer-terraform-modules.git//opentofu/modules"
  global_external_application_load_balancer_module_source = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-lb-app-ext?ref=v52.0.0"
  internal_application_load_balancer_module_source        = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-lb-app-int?ref=v52.0.0"
  gcs_bucket_module_source       = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git//modules/simple_bucket?ref=v11.0.0"
  secret_manager_module_source   = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/secret-manager?ref=v52.0.0"
  firestore_module_source        = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/firestore?ref=v52.0.0"
  certificate_manager_module_source = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/certificate-manager?ref=v52.0.0"
  spanner_instance_module_source = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/spanner-instance?ref=v52.0.0"
  spanner_backup_module_source   = "git::https://github.com/GoogleCloudPlatform/terraform-google-cloud-spanner.git//modules/schedule_spanner_backup?ref=v1.2.1"
  cloud_armor_module_source      = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-cloud-armor?ref=v52.0.0"
  memorystore_valkey_module_source = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/memorystore?ref=v52.0.0"

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

module "sm_vkey_creds" {
  source     = local.secret_manager_module_source
  project_id = var.project_id
  secrets = {
    "${local.resource_name_prefix_global}-sm-vkey-creds" = {
      deletion_protection = false
      versions = {
        default = {
          data = var.sm_vkey_creds_secret_data
        }
      }
    }
  }
}

module "sm_fraud_configs" {
  source     = local.secret_manager_module_source
  project_id = var.project_id
  secrets = {
    "${local.resource_name_prefix_global}-sm-fraud-configs" = {
      deletion_protection = false
      versions = {
        default = {
          data = var.sm_fraud_configs_secret_data
        }
      }
    }
  }
}

module "sm_gateway_creds" {
  source     = local.secret_manager_module_source
  project_id = var.project_id
  secrets = {
    "${local.resource_name_prefix_global}-sm-gateway-creds" = {
      deletion_protection = false
      versions = {
        default = {
          data = var.sm_gateway_creds_secret_data
        }
      }
    }
  }
}

module "sm_meta_access_token" {
  source     = local.secret_manager_module_source
  project_id = var.project_id
  secrets = {
    "${local.resource_name_prefix_global}-sm-meta-access-token" = {
      deletion_protection = false
      versions = {
        default = {
          data = var.sm_meta_access_token_secret_data
        }
      }
    }
  }
}

module "sm_meta_verify_token" {
  source     = local.secret_manager_module_source
  project_id = var.project_id
  secrets = {
    "${local.resource_name_prefix_global}-sm-meta-verify-token" = {
      deletion_protection = false
      versions = {
        default = {
          data = var.sm_meta_verify_token_secret_data
        }
      }
    }
  }
}

module "sm_recaptcha_config" {
  source     = local.secret_manager_module_source
  project_id = var.project_id
  secrets = {
    "${local.resource_name_prefix_global}-sm-recaptcha-config" = {
      deletion_protection = false
      versions = {
        default = {
          data = var.sm_recaptcha_config_secret_data
        }
      }
    }
  }
}

module "sm_prospect_ingestion_oauth_parameter" {
  source     = local.secret_manager_module_source
  project_id = var.project_id
  secrets = {
    "${local.resource_name_prefix_global}-sm-prospect-ingestion-oauth-parameter" = {
      deletion_protection = false
      versions = {
        default = {
          data = var.sm_prospect_ingestion_oauth_parameter_secret_data
        }
      }
    }
  }
}

# GCS Bucket Exp Configs - AADB2C, Frontend,Enrichment, Internal
module "gcs_exp_configs" {
  source                      = local.gcs_bucket_module_source
  project_id                  = var.project_id
  name                        = "${local.resource_name_prefix_global}-gcs-exp-configs"
  location                    = var.gcs_exp_configs.location
  public_access_prevention    = var.gcs_exp_configs.public_access_prevention
  bucket_policy_only          = var.gcs_exp_configs.uniform_bucket_level_access
  force_destroy               = var.gcs_exp_configs.force_destroy
}

# GCS Bucket Exp Configs - Message
module "gcs_exp_templates" {
  source                      = local.gcs_bucket_module_source
  project_id                  = var.project_id
  name                        = "${local.resource_name_prefix_global}-gcs-exp-templates"
  location                    = var.gcs_exp_templates.location
  public_access_prevention    = var.gcs_exp_templates.public_access_prevention
  bucket_policy_only          = var.gcs_exp_templates.uniform_bucket_level_access
  force_destroy               = var.gcs_exp_templates.force_destroy
}

# GCS Bucket Prospect Configs - Prospect
module "gcs_prospect_configs" {
  source                      = local.gcs_bucket_module_source
  project_id                  = var.project_id
  name                        = "${local.resource_name_prefix_global}-gcs-prospect-configs"
  location                    = var.gcs_prospect_configs.location
  public_access_prevention    = var.gcs_prospect_configs.public_access_prevention
  bucket_policy_only          = var.gcs_prospect_configs.uniform_bucket_level_access
  force_destroy               = var.gcs_prospect_configs.force_destroy
}

# GCS Bucket Prospect Dropzone - Prospect
module "gcs_prospect_dropzone" {
  source                      = local.gcs_bucket_module_source
  project_id                  = var.project_id
  name                        = "${local.resource_name_prefix_global}-gcs-prospect-dropzone"
  location                    = var.gcs_prospect_dropzone.location
  public_access_prevention    = var.gcs_prospect_dropzone.public_access_prevention
  bucket_policy_only          = var.gcs_prospect_dropzone.uniform_bucket_level_access
  force_destroy               = var.gcs_prospect_dropzone.force_destroy
}

# GCS Bucket Privacy Configs - Privacy
module "gcs_privacy_configs" {
  source                      = local.gcs_bucket_module_source
  project_id                  = var.project_id
  name                        = "${local.resource_name_prefix_global}-gcs-privacy-configs"
  location                    = var.gcs_privacy_configs.location
  public_access_prevention    = var.gcs_privacy_configs.public_access_prevention
  bucket_policy_only          = var.gcs_privacy_configs.uniform_bucket_level_access
  force_destroy               = var.gcs_privacy_configs.force_destroy
}

# GCS Bucket Privacy Configs - Privacy
module "gcs_privacy_consumer_archive" {
  source                      = local.gcs_bucket_module_source
  project_id                  = var.project_id
  name                        = "${local.resource_name_prefix_global}-gcs-privacy-consumer-archive"
  location                    = var.gcs_privacy_consumer_archive.location
  public_access_prevention    = var.gcs_privacy_consumer_archive.public_access_prevention
  bucket_policy_only          = var.gcs_privacy_consumer_archive.uniform_bucket_level_access
  force_destroy               = var.gcs_privacy_consumer_archive.force_destroy
}

# GCS Bucket AADB2C Event Dropzone - AADB2C Reporting
module "gcs_aad_b2c_event_dropzone" {
  source                      = local.gcs_bucket_module_source
  project_id                  = var.project_id
  name                        = "${local.resource_name_prefix_global}-gcs-aad-b2c-event-dropzone"
  location                    = var.gcs_aadb2c_event_dropzone.location
  public_access_prevention    = var.gcs_aadb2c_event_dropzone.public_access_prevention
  bucket_policy_only          = var.gcs_aadb2c_event_dropzone.uniform_bucket_level_access
  force_destroy               = var.gcs_aadb2c_event_dropzone.force_destroy
}

# Temporary START
# GCS Bucket cds-gcs-aad-b2c-components-cdn
module "gcs_aad_b2c_component_cdn" {
  source                      = local.gcs_bucket_module_source
  project_id                  = var.project_id
  name                        = "${local.resource_name_prefix_global}-gcs-aad-b2c-component-cdn"
  location                    = var.gcs_aad_b2c_component_cdn.location
  public_access_prevention    = var.gcs_aad_b2c_component_cdn.public_access_prevention
  bucket_policy_only          = var.gcs_aad_b2c_component_cdn.uniform_bucket_level_access
  force_destroy               = var.gcs_aad_b2c_component_cdn.force_destroy
}
 
# GCS Bucket cds-gcs-aad-b2c-components-demo
module "gcs_aad_b2c_component_demo" {
  source                      = local.gcs_bucket_module_source
  project_id                  = var.project_id
  name                        = "${local.resource_name_prefix_global}-gcs-aad-b2c-component-demo"
  location                    = var.gcs_aad_b2c_component_demo.location
  public_access_prevention    = var.gcs_aad_b2c_component_demo.public_access_prevention
  bucket_policy_only          = var.gcs_aad_b2c_component_demo.uniform_bucket_level_access
  force_destroy               = var.gcs_aad_b2c_component_demo.force_destroy
}
 
# GCS Bucket cds-gcs-aad-b2c-components-account
module "gcs_aad_b2c_component_account" {
  source                      = local.gcs_bucket_module_source
  project_id                  = var.project_id
  name                        = "${local.resource_name_prefix_global}-gcs-aad-b2c-component-account"
  location                    = var.gcs_aad_b2c_component_account.location
  public_access_prevention    = var.gcs_aad_b2c_component_account.public_access_prevention
  bucket_policy_only          = var.gcs_aad_b2c_component_account.uniform_bucket_level_access
  force_destroy               = var.gcs_aad_b2c_component_account.force_destroy
}
 
# GCS Bucket gcs-consumer-gamv2-demo-site
module "gcs_consumer_gamv2_demo_site" {
  source                      = local.gcs_bucket_module_source
  project_id                  = var.project_id
  name                        = "${local.resource_name_prefix_global}-gcs-consumer-gamv2-demo-site"
  location                    = var.gcs_consumer_gamv2_demo_site.location
  public_access_prevention    = var.gcs_consumer_gamv2_demo_site.public_access_prevention
  bucket_policy_only          = var.gcs_consumer_gamv2_demo_site.uniform_bucket_level_access
  force_destroy               = var.gcs_consumer_gamv2_demo_site.force_destroy
}
 
# GCS Bucket gcs-processor-configs - Dataprocessor services
module "gcs_processor_configs" {
  source                      = local.gcs_bucket_module_source
  project_id                  = var.project_id
  name                        = "${local.resource_name_prefix_global}-gcs-processor-configs"
  location                    = var.gcs_processor_configs.location
  public_access_prevention    = var.gcs_processor_configs.public_access_prevention
  bucket_policy_only          = var.gcs_processor_configs.uniform_bucket_level_access
  force_destroy               = var.gcs_processor_configs.force_destroy
}
# Temporary END
 
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
  source     = "${local.modules_source_repo}/global_external_address"
  project_id = var.mgmt_project_id
  name       = "${local.resource_name_prefix_global}-ip-marketing-api-edge"
}

# Cloud Armor - ca-marketing-api-security
module "ca_marketing_api_security" {
  source           = local.cloud_armor_module_source
  project_id       = var.project_id
  cloud_armor_name = "${local.resource_name_prefix_global}-ca-marketing-api-security"
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
  lb_name               = "${local.resource_name_prefix_global}-lb-marketing-api-edge"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  https_redirect        = true
  ssl                   = true
  certificate_map       = "//certificatemanager.googleapis.com/${module.certificate_manager_marketing_api_edge.map_id}"
  ip_address            = module.ip_marketing_api_edge.id
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
  cloud_armor_name = "${local.resource_name_prefix_global}-ca-message-api-security"
}

# Cloud Armor - ca-internal-api-security
module "internal_api_security" {
  source           = local.cloud_armor_module_source
  project_id       = var.project_id
  cloud_armor_name = "${local.resource_name_prefix_global}-internal-api-security"
}

# Cloud Armor - ca-privacy-api-security
module "privacy_api_security" {
  source           = local.cloud_armor_module_source
  project_id       = var.project_id
  cloud_armor_name = "${local.resource_name_prefix_global}-privacy-api-security"
}

# Cloud Armor - ca-prospect-api-security
module "prospect_api_security" {
  source           = local.cloud_armor_module_source
  project_id       = var.project_id
  cloud_armor_name = "${local.resource_name_prefix_global}-prospect-api-security"
}

# [ Dedicated API Edge START ]
# Reserved IP - dedicated-api-edge
module "ip_dedicated_api_edge" {
  source     = "${local.modules_source_repo}/global_external_address"
  project_id = var.project_id
  name       = "${local.resource_name_prefix_global}-ip-dedicated-api-edge"
}

# Cloud Armor - ca-aad-b2c-api-security
module "ca_aad_b2c_api_security" {
  source           = local.cloud_armor_module_source
  project_id       = var.project_id
  cloud_armor_name = "${local.resource_name_prefix_global}-ca-aad-b2c-api-security"
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
  lb_name               = "${local.resource_name_prefix_global}-lb-dedicated-api-edge"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  https_redirect        = true
  ssl                   = true
  certificate_map       = "//certificatemanager.googleapis.com/${module.certificate_manager_dedicated_api_edge.map_id}"
  ip_address            = module.ip_dedicated_api_edge.id
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
      bucket_name = module.gcs_exp_configs.name
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
  count                = contains(["alpha", "beta", "gamma", "prod"], lower(var.environment)) ? 1 : 0
  source               = "${local.modules_source_repo}/internal_address"
  name                 = "${local.resource_name_prefix_primary}-ip-marketing"
  project_id           = var.project_id
  region               = local.region["PRIMARY"]
  address              = "10.0.8.150"
  subnetwork_self_link = data.google_compute_subnetwork.ilb_subnet_primary[0].self_link
}

module "ip_marketing_ilb_secondary" {
  count                = contains(["gamma", "prod"], lower(var.environment)) ? 1 : 0
  source               = "${local.modules_source_repo}/internal_address"
  name                 = "${local.resource_name_prefix_secondary}-ip-marketing"
  project_id           = var.project_id
  region               = local.region["SECONDARY"]
  address              = "10.0.8.250"
  subnetwork_self_link = data.google_compute_subnetwork.ilb_subnet_secondary[0].self_link
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
data "google_cloud_run_v2_service" "frontend_update_consumer_primary" {
  count    = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  project  = var.project_id
  location = local.region["PRIMARY"]
  name     = "${local.resource_name_prefix_primary}-run-frontend-update-consumer"
}

# Serverless NEG 
module "serverless_neg_run_frontend_update_consumer_primary" {
  count      = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  source     = "${local.modules_source_repo}/region_network_endpoint_group"
  name       = "${local.resource_name_prefix_primary}-neg-frontend-update-consumer"
  project_id = var.project_id
  region     = local.region["PRIMARY"]
  cloud_run = {
    service = data.google_cloud_run_v2_service.frontend_update_consumer_primary[0].name
  }
}

data "google_cloud_run_v2_service" "frontend_get_consumer_primary" {
  count    = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  project  = var.project_id
  location = local.region["PRIMARY"]
  name     = "${local.resource_name_prefix_primary}-run-frontend-get-consumer"
}

# Serverless NEG
module "serverless_neg_run_frontend_get_consumer_primary" {
  count      = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  source     = "${local.modules_source_repo}/region_network_endpoint_group"
  name       = "${local.resource_name_prefix_primary}-neg-frontend-get-consumer"
  project_id = var.project_id
  region     = local.region["PRIMARY"]
  cloud_run = {
    service = data.google_cloud_run_v2_service.frontend_get_consumer_primary[0].name
  }
}

data "google_cloud_run_v2_service" "message_event_processor_primary" {
  count    = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  project  = var.project_id
  location = local.region["PRIMARY"]
  name     = "${local.resource_name_prefix_primary}-run-message-event-processor"
}

# Serverless NEG
module "serverless_neg_run_message_event_processor_primary" {
  count      = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  source     = "${local.modules_source_repo}/region_network_endpoint_group"
  name       = "${local.resource_name_prefix_primary}-neg-message-event-processor"
  project_id = var.project_id
  region     = local.region["PRIMARY"]
  cloud_run = {
    service = data.google_cloud_run_v2_service.message_event_processor_primary[0].name
  }
}

data "google_cloud_run_v2_service" "enrichment_get_data_primary" {
  count    = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  project  = var.project_id
  location = local.region["PRIMARY"]
  name     = "${local.resource_name_prefix_primary}-run-enrichment-get-data"
}

# Serverless NEG
module "serverless_neg_run_enrichment_get_data_primary" {
  count      = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  source     = "${local.modules_source_repo}/region_network_endpoint_group"
  name       = "${local.resource_name_prefix_primary}-neg-enrichment-get-data"
  project_id = var.project_id
  region     = local.region["PRIMARY"]
  cloud_run = {
    service = data.google_cloud_run_v2_service.enrichment_get_data_primary[0].name
  }
}

data "google_cloud_run_v2_service" "enrichment_put_data_primary" {
  count    = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  project  = var.project_id
  location = local.region["PRIMARY"]
  name     = "${local.resource_name_prefix_primary}-run-enrichment-put-data"
}

# Serverless NEG
module "serverless_neg_run_enrichment_put_data_primary" {
  count      = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  source     = "${local.modules_source_repo}/region_network_endpoint_group"
  name       = "${local.resource_name_prefix_primary}-neg-enrichment-put-data"
  project_id = var.project_id
  region     = local.region["PRIMARY"]
  cloud_run = {
    service = data.google_cloud_run_v2_service.enrichment_put_data_primary[0].name
  }
}

# Internal Application LB
module "lb_marketing_primary" {
  count                = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  source               = local.internal_application_load_balancer_module_source
  project_id           = var.project_id
  region               = local.region["PRIMARY"]
  lb_name              = "${local.resource_name_prefix_primary}-lb-marketing"
  subnetwork_self_link = data.google_compute_subnetwork.ilb_subnet_primary[0].self_link
  ip_address           = module.ip_marketing_ilb_primary[0].id
  protocol             = "HTTP"
  ip_protocol          = "TCP"
  port_range           = "80"
  default_backend_key  = "frontend-update-consumer"

  backends = {
    frontend-update-consumer = {
      group = module.serverless_neg_run_frontend_update_consumer_primary[0].id
    },
    frontend-get-consumer = {
      group = module.serverless_neg_run_frontend_get_consumer_primary[0].id
    },
    message-event-processor = {
      group = module.serverless_neg_run_message_event_processor_primary[0].id
    },
    enrichment-get-data = {
      group = module.serverless_neg_run_enrichment_get_data_primary[0].id
    },
    enrichment-put-data = {
      group = module.serverless_neg_run_enrichment_put_data_primary[0].id
    }
  }
  host_rules = [
    {
      hosts        = ["*"]
      path_matcher = "api-paths"
    }
  ]
  path_matchers = {
    "api-paths" = {
      default_service = "${local.resource_name_prefix_global}-lb-marketing-frontend-get-consumer"
      rules = [
        {
          paths   = ["/v2/consumers/update"]
          service = "${local.resource_name_prefix_global}-lb-marketing-frontend-update-consumer"
        },
        {
          paths   = ["/v2/consumers"]
          service = "${local.resource_name_prefix_global}-lb-marketing-frontend-get-consumer"
        },
        {
          paths   = ["/message-event-processor/*"]
          service = "${local.resource_name_prefix_global}-lb-marketing-message-event-processor"
        },
        {
          paths   = ["/enrichment-get-data/*"]
          service = "${local.resource_name_prefix_global}-lb-marketing-enrichment-get-data"
        },
        {
          paths   = ["/enrichment-put-data/*"]
          service = "${local.resource_name_prefix_global}-lb-marketing-enrichment-put-data"
        }
      ]
    }
  }
}
# [ Internal Application LB - Marketing END ]

# Service Attachment Southbound - Marketing
module "service_attachment_marketing_primary" {
  count                 = length(module.lb_marketing_primary)
  source                = "${local.modules_source_repo}/service_attachment"
  project_id            = var.project_id
  region                = local.region["PRIMARY"]
  name                  = "${local.resource_name_prefix_primary}-att-marketing"
  connection_preference = "ACCEPT_AUTOMATIC"
  target_service        = module.lb_marketing_primary[0].forwarding_rule.self_link
  enable_proxy_protocol = false
  nat_subnets           = [data.google_compute_subnetwork.psc_subnet_primary[0].id]
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
data "google_cloud_run_v2_service" "frontend_update_consumer_secondary" {
  count    = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  project  = var.project_id
  location = local.region["SECONDARY"]
  name     = "${local.resource_name_prefix_secondary}-run-frontend-update-consumer"
}

# Serverless NEG 
module "serverless_neg_run_frontend_update_consumer_secondary" {
  count      = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  source     = "${local.modules_source_repo}/region_network_endpoint_group"
  name       = "${local.resource_name_prefix_secondary}-neg-frontend-update-consumer"
  project_id = var.project_id
  region     = local.region["SECONDARY"]
  cloud_run = {
    service = data.google_cloud_run_v2_service.frontend_update_consumer_secondary[0].name
  }
}

data "google_cloud_run_v2_service" "frontend_get_consumer_secondary" {
  count    = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  project  = var.project_id
  location = local.region["SECONDARY"]
  name     = "${local.resource_name_prefix_secondary}-run-frontend-get-consumer"
}

# Serverless NEG
module "serverless_neg_run_frontend_get_consumer_secondary" {
  count      = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  source     = "${local.modules_source_repo}/region_network_endpoint_group"
  name       = "${local.resource_name_prefix_secondary}-neg-frontend-get-consumer"
  project_id = var.project_id
  region     = local.region["SECONDARY"]
  cloud_run = {
    service = data.google_cloud_run_v2_service.frontend_get_consumer_secondary[0].name
  }
}

data "google_cloud_run_v2_service" "message_event_processor_secondary" {
  count    = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  project  = var.project_id
  location = local.region["SECONDARY"]
  name     = "${local.resource_name_prefix_secondary}-run-message-event-processor"
}

# Serverless NEG
module "serverless_neg_run_message_event_processor_secondary" {
  count      = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  source     = "${local.modules_source_repo}/region_network_endpoint_group"
  name       = "${local.resource_name_prefix_secondary}-neg-message-event-processor"
  project_id = var.project_id
  region     = local.region["SECONDARY"]
  cloud_run = {
    service = data.google_cloud_run_v2_service.message_event_processor_secondary[0].name
  }
}

data "google_cloud_run_v2_service" "enrichment_get_data_secondary" {
  count    = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  project  = var.project_id
  location = local.region["SECONDARY"]
  name     = "${local.resource_name_prefix_secondary}-run-enrichment-get-data"
}

# Serverless NEG
module "serverless_neg_run_enrichment_get_data_secondary" {
  count      = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  source     = "${local.modules_source_repo}/region_network_endpoint_group"
  name       = "${local.resource_name_prefix_secondary}-neg-enrichment-get-data"
  project_id = var.project_id
  region     = local.region["SECONDARY"]
  cloud_run = {
    service = data.google_cloud_run_v2_service.enrichment_get_data_secondary[0].name
  }
}

data "google_cloud_run_v2_service" "enrichment_put_data_secondary" {
  count    = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  project  = var.project_id
  location = local.region["SECONDARY"]
  name     = "${local.resource_name_prefix_secondary}-run-enrichment-put-data"
}

# Serverless NEG
module "serverless_neg_run_enrichment_put_data_secondary" {
  count      = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  source     = "${local.modules_source_repo}/region_network_endpoint_group"
  name       = "${local.resource_name_prefix_secondary}-neg-enrichment-put-data"
  project_id = var.project_id
  region     = local.region["SECONDARY"]
  cloud_run = {
    service = data.google_cloud_run_v2_service.enrichment_put_data_secondary[0].name
  }
}

# Internal Application LB
module "lb_marketing_secondary" {
  count                = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  source               = local.internal_application_load_balancer_module_source
  project_id           = var.project_id
  region               = local.region["SECONDARY"]
  lb_name              = "${local.resource_name_prefix_secondary}-lb-marketing"
  subnetwork_self_link = data.google_compute_subnetwork.ilb_subnet_secondary[0].self_link
  ip_address           = module.ip_marketing_ilb_secondary[0].id
  protocol             = "HTTP"
  ip_protocol          = "TCP"
  port_range           = "80"
  default_backend_key  = "frontend-update-consumer"

  backends = {
    frontend-update-consumer = {
      group = module.serverless_neg_run_frontend_update_consumer_secondary[0].id
    },
    frontend-get-consumer = {
      group = module.serverless_neg_run_frontend_get_consumer_secondary[0].id
    },
    message-event-processor = {
      group = module.serverless_neg_run_message_event_processor_secondary[0].id
    },
    enrichment-get-data = {
      group = module.serverless_neg_run_enrichment_get_data_secondary[0].id
    },
    enrichment-put-data = {
      group = module.serverless_neg_run_enrichment_put_data_secondary[0].id
    }
  }
  host_rules = [
    {
      hosts        = ["*"]
      path_matcher = "api-paths"
    }
  ]
  path_matchers = {
    "api-paths" = {
      default_service = "${local.resource_name_prefix_global}-lb-marketing-frontend-get-consumer"
      rules = [
        {
          paths   = ["/update-consumer/*"]
          service = "${local.resource_name_prefix_global}-lb-marketing-frontend-update-consumer"
        },
        {
          paths   = ["/get-consumer/*"]
          service = "${local.resource_name_prefix_global}-lb-marketing-frontend-get-consumer"
        },
        {
          paths   = ["/message-event-processor/*"]
          service = "${local.resource_name_prefix_global}-lb-marketing-message-event-processor"
        },
        {
          paths   = ["/enrichment-get-data/*"]
          service = "${local.resource_name_prefix_global}-lb-marketing-enrichment-get-data"
        },
        {
          paths   = ["/enrichment-put-data/*"]
          service = "${local.resource_name_prefix_global}-lb-marketing-enrichment-put-data"
        }
      ]
    }
  }
}
# [ Internal Application LB - Marketing END ]

# Service Attachment Southbound - Marketing
module "service_attachment_marketing_secondary" {
  count                 = length(module.lb_marketing_secondary)
  source                = "${local.modules_source_repo}/service_attachment"
  project_id            = var.project_id
  region                = local.region["SECONDARY"]
  name                  = "${local.resource_name_prefix_secondary}-att-marketing"
  connection_preference = "ACCEPT_AUTOMATIC"
  target_service        = module.lb_marketing_secondary[0].forwarding_rule.self_link
  enable_proxy_protocol = false
  nat_subnets           = [data.google_compute_subnetwork.psc_subnet_secondary[0].id]
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
