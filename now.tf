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

  # For gamma and prod, assign regional prefixes. For other environments, keep prefixes empty.
  regional_prefixes              = contains(["gamma", "prod"], lower(var.environment)) ? ["-pri", "-sec"] : ["", ""]
  resource_name_prefix_primary   = format("%s-%s%s", var.environment, var.app_code, local.regional_prefixes[0])
  resource_name_prefix_secondary = format("%s-%s%s", var.environment, var.app_code, local.regional_prefixes[1])
  resource_name_prefix_global    = format("%s-%s", var.environment, var.app_code)

  # Global External Application LB - Marketing API Edge
  marketing_api_edge_serverless_backend_services = {
    # For Temporary Validations Only
    frontend-get-consumer = {
      name            = "frontend-get-consumer"
      security_policy = module.ca_marketing_api_security.policy.self_link
    }
    frontend-update-consumer = {
      name            = "frontend-update-consumer"
      security_policy = module.ca_marketing_api_security.policy.self_link
    }
  }

  marketing_api_edge_path_matchers = {
    "api-paths" = {
      default_service = "frontend-get-consumer"
      path_rules = [
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
      security_policy = module.ca_aad_b2c_api_security.policy.self_link
    }
    aad-b2c-create-consumer = {
      name            = "aad-b2c-create-consumer"
      security_policy = module.ca_aad_b2c_api_security.policy.self_link
    }
    aad-b2c-delete-consumer = {
      name            = "aad-b2c-delete-consumer"
      security_policy = module.ca_aad_b2c_api_security.policy.self_link
    }
    aad-b2c-get-consumer = {
      name            = "aad-b2c-get-consumer"
      security_policy = module.ca_aad_b2c_api_security.policy.self_link
    }
    aad-b2c-send-message = {
      name            = "aad-b2c-send-message"
      security_policy = module.ca_aad_b2c_api_security.policy.self_link
    }
    aad-b2c-assess-consumer = {
      name            = "aad-b2c-assess-consumer"
      security_policy = module.ca_aad_b2c_api_security.policy.self_link
    }
    aad-b2c-assess-fraud = {
      name            = "aad-b2c-assess-fraud"
      security_policy = module.ca_aad_b2c_api_security.policy.self_link
    }
    aad-b2c-update-consumer = {
      name            = "aad-b2c-update-consumer"
      security_policy = module.ca_aad_b2c_api_security.policy.self_link
    }
    internal-services = {
      name            = "internal-services"
      security_policy = module.internal_api_security.policy.self_link
      iap_config = {
        enable = true
      }
    }
    privacy-show-my-data = {
      name            = "privacy-show-my-data"
      security_policy = module.privacy_api_security.policy.self_link
    }
    privacy-unsubscribe = {
      name            = "privacy-unsubscribe"
      security_policy = module.privacy_api_security.policy.self_link
    }
    privacy-forget-me = {
      name            = "privacy-forget-me"
      security_policy = module.privacy_api_security.policy.self_link
    }
    prosp-dataflow-invoker = {
      name            = "prospect-dataflow-invoker"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-delete = {
      name            = "prospect-delete"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-email-processor = {
      name            = "prospect-email-processor"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-fetch = {
      name            = "prospect-fetch"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-forget-me = {
      name            = "prospect-forget-me"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-generic-processor = {
      name            = "prospect-generic-processor"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-google-processor = {
      name            = "prospect-google-processor"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-internal-processor = {
      name            = "prospect-internal-processor"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-latam-processor = {
      name            = "prospect-latam-processor"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-meta-processor = {
      name            = "prospect-meta-processor"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-meta-verify-token = {
      name            = "prospect-meta-verify-token"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-oauth-processor = {
      name            = "prospect-oauth-processor"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-show-my-data = {
      name            = "prospect-show-my-data"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-snapchat-generator = {
      name            = "prospect-snapchat-generator"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-snapchat-processor = {
      name            = "prospect-snapchat-processor"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-tiktok-dl-leads = {
      name            = "prospect-tiktok-dl-leads"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-tiktok-leads = {
      name            = "prospect-tiktok-leads"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-tiktok-processor = {
      name            = "prospect-tiktok-processor"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-tiktok-subscribe = {
      name            = "prospect-tiktok-subscribe"
      security_policy = module.prospect_api_security.policy.self_link
    }
    prosp-unsubscribe-me = {
      name            = "prospect-unsubscribe-me"
      security_policy = module.prospect_api_security.policy.self_link
    }
  }
  dedicated_api_edge_path_matchers = {
    "api-paths" = {
      default_service = "aad-b2c-auth-consumer"
      path_rules = [
        { paths = ["/static/*"], service = "gcs" },
        { paths = ["/privacy-show-my-data/*"], service = "privacy-show-my-data" },
        { paths = ["/privacy-unsubscribe/*"], service = "privacy-unsubscribe" },
        { paths = ["/privacy-forget-me/*"], service = "privacy-forget-me" },
      ]
    }
    "aadb2c-services-paths" = {
      default_service = "aad-b2c-auth-consumer"
      route_rules = [
        {
          priority = 1
          service  = "aad-b2c-assess-fraud"
          match_rules = [{
            path    = { value = "/v2/validate-fraud", type = "full" }
            headers = [{ name = ":method", type = "exact", value = "POST" }]
          }]
        },
        {
          priority = 2
          service  = "aad-b2c-auth-consumer"
          match_rules = [{ path = { value = "/validate-consumer", type = "prefix" } }]
        },
        {
          priority = 3
          service  = "aad-b2c-create-consumer"
          match_rules = [{ path = { value = "/v2/consumers/create", type = "prefix" } }]
        },
        {
          priority = 4
          service  = "aad-b2c-delete-consumer"
          match_rules = [{ path = { value = "/v2/consumers/delete", type = "prefix" } }]
        },
        {
          priority = 5
          service  = "aad-b2c-get-consumer"
          match_rules = [{ path = { value = "/v2/consumers", type = "prefix" } }]
        },
        {
          priority = 6
          service  = "aad-b2c-send-message"
          match_rules = [{ path = { value = "/v2/messages", type = "prefix" } }]
        },
        {
          priority = 7
          service  = "aad-b2c-assess-consumer"
          match_rules = [{ path = { value = "/assess-consumer/*", type = "prefix" } }]
        },
        {
          priority = 8
          service  = "aad-b2c-update-consumer"
          match_rules = [{ path = { value = "/v2/consumers/update", type = "prefix" } }]
        }
      ]
    },
    "internal-services-paths" = {
      default_service = "internal-services"
      route_rules = [
        {
          priority = 1
          service  = "internal-services"
          match_rules = [{
            path    = { value = "/v2/consumers", type = "full" }
            headers = [{ name = ":method", type = "exact", value = "POST" }]
          }]
        }
      ]
    },
    "prospect-services-paths" = {
      default_service = "prosp-fetch"
      route_rules = [
        {
          priority = 1
          service  = "prosp-delete"
          match_rules = [{
            path    = { value = "/v2/prospects", type = "full" }
            headers = [{ name = ":method", type = "exact", value = "DELETE" }]
          }]
        },
        {
          priority = 2
          service  = "prosp-fetch"
          match_rules = [{
            path    = { value = "/v2/prospects", type = "full" }
            headers = [{ name = ":method", type = "exact", value = "GET" }]
          }]
        },
        {
          priority = 3
          service  = "prosp-dataflow-invoker"
          match_rules = [{ path = { value = "/prosp-dataflow-invoker/", type = "prefix" } }]
        },
        {
          priority = 4
          service  = "prosp-email-processor"
          match_rules = [{ path = { value = "/prosp-email-processor/", type = "prefix" } }]
        },
        {
          priority = 5
          service  = "prosp-forget-me"
          match_rules = [{ path = { value = "/v2/delete-my-data", type = "full" } }]
        },
        {
          priority = 6
          service  = "prosp-generic-processor"
          match_rules = [{ path = { value = "/prosp-generic-processor/", type = "prefix" } }]
        },
        {
          priority = 7
          service  = "prosp-google-processor"
          match_rules = [{ path = { value = "/v2/processors/google", type = "full" } }]
        },
        {
          priority = 8
          service  = "prosp-internal-processor"
          match_rules = [{ path = { value = "/prosp-internal-processor/", type = "prefix" } }]
        },
        {
          priority = 9
          service  = "prosp-latam-processor"
          match_rules = [{ path = { value = "/v2/processors/latam", type = "full" } }]
        },
        {
          priority = 10
          service  = "prosp-meta-processor"
          match_rules = [{ path = { value = "/prosp-meta-processor/", type = "prefix" } }]
        },
        {
          priority = 11
          service  = "prosp-meta-verify-token"
          match_rules = [{ path = { value = "/v2/meta-verify-token", type = "full" } }]
        },
        {
          priority = 12
          service  = "prosp-oauth-processor"
          match_rules = [{ path = { value = "/prosp-oauth-processor/", type = "prefix" } }]
        },
        {
          priority = 13
          service  = "prosp-show-my-data"
          match_rules = [{ path = { value = "/v2/show-my-data", type = "full" } }]
        },
        {
          priority = 14
          service  = "prosp-snapchat-generator"
          match_rules = [{ path = { value = "/prosp-snapchat-generator/", type = "prefix" } }]
        },
        {
          priority = 15
          service  = "prosp-snapchat-processor"
          match_rules = [{ path = { value = "/prosp-snapchat-processor/", type = "prefix" } }]
        },
        {
          priority = 16
          service  = "prosp-tiktok-dl-leads"
          match_rules = [{ path = { value = "/prosp-tiktok-dl-leads/", type = "prefix" } }]
        },
        {
          priority = 17
          service  = "prosp-tiktok-leads"
          match_rules = [{ path = { value = "/v2/processors/tiktok/leads", type = "full" } }]
        },
        {
          priority = 18
          service  = "prosp-tiktok-processor"
          match_rules = [{ path = { value = "/v2/processors/tiktok", type = "full" } }]
        },
        {
          priority = 19
          service  = "prosp-tiktok-subscribe"
          match_rules = [{ path = { value = "/v2/processors/tiktok/subscribe", type = "full" } }]
        },
        {
          priority = 20
          service  = "prosp-unsubscribe-me"
          match_rules = [{ path = { value = "/v2/unsubscribe", type = "full" } }]
        },
        {
          priority = 21
          service  = "prosp-delete"
          match_rules = [{
            path    = { value = "/v2/{koRegion=*}/prospects/{hashedKocid=*}", type = "template" }
            headers = [{ name = ":method", type = "exact", value = "DELETE" }]
          }]
        },
        {
          priority = 22
          service  = "prosp-fetch"
          match_rules = [{
            path    = { value = "/v2/{koRegion=*}/prospects/{hashedKocid=*}", type = "template" }
            headers = [{ name = ":method", type = "exact", value = "GET" }]
          }]
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
  source     = "git::https://github.com/GoogleCloudPlatform/terraform-google-secret-manager.git?ref=v0.9.0"
  project_id = var.project_id
  secrets = [
    {
      name        = "${local.resource_name_prefix_global}-sm-vkey-creds"
      secret_data = var.sm_vkey_creds_secret_data
    }
  ]
}

module "sm_fraud_configs" {
  source     = "git::https://github.com/GoogleCloudPlatform/terraform-google-secret-manager.git?ref=v0.9.0"
  project_id = var.project_id
  secrets = [
    {
      name        = "${local.resource_name_prefix_global}-sm-fraud-configs"
      secret_data = var.sm_fraud_configs_secret_data
    }
  ]
}

module "sm_gateway_creds" {
  source     = "git::https://github.com/GoogleCloudPlatform/terraform-google-secret-manager.git?ref=v0.9.0"
  project_id = var.project_id
  secrets = [
    {
      name        = "${local.resource_name_prefix_global}-sm-gateway-creds"
      secret_data = var.sm_gateway_creds_secret_data
    }
  ]
}

module "sm_meta_access_token" {
  source     = "git::https://github.com/GoogleCloudPlatform/terraform-google-secret-manager.git?ref=v0.9.0"
  project_id = var.project_id
  secrets = [
    {
      name        = "${local.resource_name_prefix_global}-sm-meta-access-token"
      secret_data = var.sm_meta_access_token_secret_data
    }
  ]
}

module "sm_meta_verify_token" {
  source     = "git::https://github.com/GoogleCloudPlatform/terraform-google-secret-manager.git?ref=v0.9.0"
  project_id = var.project_id
  secrets = [
    {
      name        = "${local.resource_name_prefix_global}-sm-meta-verify-token"
      secret_data = var.sm_meta_verify_token_secret_data
    }
  ]
}

module "sm_recaptcha_config" {
  source     = "git::https://github.com/GoogleCloudPlatform/terraform-google-secret-manager.git?ref=v0.9.0"
  project_id = var.project_id
  secrets = [
    {
      name        = "${local.resource_name_prefix_global}-sm-recaptcha-config"
      secret_data = var.sm_recaptcha_config_secret_data
    }
  ]
}

module "sm_prospect_ingestion_oauth_parameter" {
  source     = "git::https://github.com/GoogleCloudPlatform/terraform-google-secret-manager.git?ref=v0.9.0"
  project_id = var.project_id
  secrets = [
    {
      name        = "${local.resource_name_prefix_global}-sm-prospect-ingestion-oauth-parameter"
      secret_data = var.sm_prospect_ingestion_oauth_parameter_secret_data
    }
  ]
}

# GCS Bucket Exp Configs - AADB2C, Frontend,Enrichment, Internal
module "gcs_exp_configs" {
  source     = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git?ref=v12.3.0"
  project_id = var.project_id
  prefix     = local.resource_name_prefix_global
  names      = ["gcs-exp-configs"]
  location   = var.gcs_exp_configs.location
  public_access_prevention = var.gcs_exp_configs.public_access_prevention
  bucket_policy_only = {
    "gcs-exp-configs" = var.gcs_exp_configs.uniform_bucket_level_access
  }
  force_destroy = {
    "gcs-exp-configs" = var.gcs_exp_configs.force_destroy
  }
}

# GCS Bucket Exp Configs - Message
module "gcs_exp_templates" {
  source     = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git?ref=v12.3.0"
  project_id = var.project_id
  prefix     = local.resource_name_prefix_global
  names      = ["gcs-exp-templates"]
  location   = var.gcs_exp_templates.location
  public_access_prevention = var.gcs_exp_templates.public_access_prevention
  bucket_policy_only = {
    "gcs-exp-templates" = var.gcs_exp_templates.uniform_bucket_level_access
  }
  force_destroy = {
    "gcs-exp-templates" = var.gcs_exp_templates.force_destroy
  }
}

# GCS Bucket Prospect Configs - Prospect
module "gcs_prospect_configs" {
  source     = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git?ref=v12.3.0"
  project_id = var.project_id
  prefix     = local.resource_name_prefix_global
  names      = ["gcs-prospect-configs"]
  location   = var.gcs_prospect_configs.location
  public_access_prevention = var.gcs_prospect_configs.public_access_prevention
  bucket_policy_only = {
    "gcs-prospect-configs" = var.gcs_prospect_configs.uniform_bucket_level_access
  }
  force_destroy = {
    "gcs-prospect-configs" = var.gcs_prospect_configs.force_destroy
  }
}

# GCS Bucket Prospect Dropzone - Prospect
module "gcs_prospect_dropzone" {
  source     = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git?ref=v12.3.0"
  project_id = var.project_id
  prefix     = local.resource_name_prefix_global
  names      = ["gcs-prospect-dropzone"]
  location   = var.gcs_prospect_dropzone.location
  public_access_prevention = var.gcs_prospect_dropzone.public_access_prevention
  bucket_policy_only = {
    "gcs-prospect-dropzone" = var.gcs_prospect_dropzone.uniform_bucket_level_access
  }
  force_destroy = {
    "gcs-prospect-dropzone" = var.gcs_prospect_dropzone.force_destroy
  }
}

# GCS Bucket Privacy Configs - Privacy
module "gcs_privacy_configs" {
  source     = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git?ref=v12.3.0"
  project_id = var.project_id
  prefix     = local.resource_name_prefix_global
  names      = ["gcs-privacy-configs"]
  location   = var.gcs_privacy_configs.location
  public_access_prevention = var.gcs_privacy_configs.public_access_prevention
  bucket_policy_only = {
    "gcs-privacy-configs" = var.gcs_privacy_configs.uniform_bucket_level_access
  }
  force_destroy = {
    "gcs-privacy-configs" = var.gcs_privacy_configs.force_destroy
  }
}

# GCS Bucket Privacy Configs - Privacy
module "gcs_privacy_consumer_archive" {
  source     = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git?ref=v12.3.0"
  project_id = var.project_id
  prefix     = local.resource_name_prefix_global
  names      = ["gcs-privacy-consumer-archive"]
  location   = var.gcs_privacy_consumer_archive.location
  public_access_prevention = var.gcs_privacy_consumer_archive.public_access_prevention
  bucket_policy_only = {
    "gcs-privacy-consumer-archive" = var.gcs_privacy_consumer_archive.uniform_bucket_level_access
  }
  force_destroy = {
    "gcs-privacy-consumer-archive" = var.gcs_privacy_consumer_archive.force_destroy
  }
}

# GCS Bucket AADB2C Event Dropzone - AADB2C Reporting
module "gcs_aad_b2c_event_dropzone" {
  source     = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git?ref=v12.3.0"
  project_id = var.project_id
  prefix     = local.resource_name_prefix_global
  names      = ["gcs-aad-b2c-event-dropzone"]
  location   = var.gcs_aadb2c_event_dropzone.location
  public_access_prevention = var.gcs_aadb2c_event_dropzone.public_access_prevention
  bucket_policy_only = {
    "gcs-aad-b2c-event-dropzone" = var.gcs_aadb2c_event_dropzone.uniform_bucket_level_access
  }
  force_destroy = {
    "gcs-aad-b2c-event-dropzone" = var.gcs_aadb2c_event_dropzone.force_destroy
  }
}

# Temporary START
# GCS Bucket cds-gcs-aad-b2c-components-cdn
module "gcs_aad_b2c_component_cdn" {
  source     = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git?ref=v12.3.0"
  project_id = var.project_id
  prefix     = local.resource_name_prefix_global
  names      = ["gcs-aad-b2c-component-cdn"]
  location   = var.gcs_aad_b2c_component_cdn.location
  public_access_prevention = var.gcs_aad_b2c_component_cdn.public_access_prevention
  bucket_policy_only = {
    "gcs-aad-b2c-component-cdn" = var.gcs_aad_b2c_component_cdn.uniform_bucket_level_access
  }
  force_destroy = {
    "gcs-aad-b2c-component-cdn" = var.gcs_aad_b2c_component_cdn.force_destroy
  }
}
 
# GCS Bucket cds-gcs-aad-b2c-components-demo
module "gcs_aad_b2c_component_demo" {
  source     = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git?ref=v12.3.0"
  project_id = var.project_id
  prefix     = local.resource_name_prefix_global
  names      = ["gcs-aad-b2c-component-demo"]
  location   = var.gcs_aad_b2c_component_demo.location
  public_access_prevention = var.gcs_aad_b2c_component_demo.public_access_prevention
  bucket_policy_only = {
    "gcs-aad-b2c-component-demo" = var.gcs_aad_b2c_component_demo.uniform_bucket_level_access
  }
  force_destroy = {
    "gcs-aad-b2c-component-demo" = var.gcs_aad_b2c_component_demo.force_destroy
  }
}
 
# GCS Bucket cds-gcs-aad-b2c-components-account
module "gcs_aad_b2c_component_account" {
  source     = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git?ref=v12.3.0"
  project_id = var.project_id
  prefix     = local.resource_name_prefix_global
  names      = ["gcs-aad-b2c-component-account"]
  location   = var.gcs_aad_b2c_component_account.location
  public_access_prevention = var.gcs_aad_b2c_component_account.public_access_prevention
  bucket_policy_only = {
    "gcs-aad-b2c-component-account" = var.gcs_aad_b2c_component_account.uniform_bucket_level_access
  }
  force_destroy = {
    "gcs-aad-b2c-component-account" = var.gcs_aad_b2c_component_account.force_destroy
  }
}
 
# GCS Bucket gcs-consumer-gamv2-demo-site
module "gcs_consumer_gamv2_demo_site" {
  source     = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git?ref=v12.3.0"
  project_id = var.project_id
  prefix     = local.resource_name_prefix_global
  names      = ["gcs-consumer-gamv2-demo-site"]
  location   = var.gcs_consumer_gamv2_demo_site.location
  public_access_prevention = var.gcs_consumer_gamv2_demo_site.public_access_prevention
  bucket_policy_only = {
    "gcs-consumer-gamv2-demo-site" = var.gcs_consumer_gamv2_demo_site.uniform_bucket_level_access
  }
  force_destroy = {
    "gcs-consumer-gamv2-demo-site" = var.gcs_consumer_gamv2_demo_site.force_destroy
  }
}
 
# GCS Bucket gcs-processor-configs - Dataprocessor services
module "gcs_processor_configs" {
  source     = "git::https://github.com/terraform-google-modules/terraform-google-cloud-storage.git?ref=v12.3.0"
  project_id = var.project_id
  prefix     = local.resource_name_prefix_global
  names      = ["gcs-processor-configs"]
  location   = var.gcs_processor_configs.location
  public_access_prevention = var.gcs_processor_configs.public_access_prevention
  bucket_policy_only = {
    "gcs-processor-configs" = var.gcs_processor_configs.uniform_bucket_level_access
  }
  force_destroy = {
    "gcs-processor-configs" = var.gcs_processor_configs.force_destroy
  }
}
# Temporary END
 
# Firestore - Privacy
module "fs_main_database" {
  source     = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/firestore?ref=v52.0.0"
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
  source                       = "./modules/cloud_spanner_instance"
  project_id                   = var.project_id
  instance_name                = "${local.resource_name_prefix_global}-spn-main-instance"
  instance_display_name        = "${local.resource_name_prefix_global}-spn"
  instance_config              = var.spn_main_instance.instance_config
  edition                      = var.spn_main_instance.edition
  num_nodes                    = var.spn_main_instance.num_nodes
  enable_autoscaling           = var.spn_main_instance.enable_autoscaling
  default_backup_schedule_type = var.spn_main_instance.default_backup_schedule_type
  force_destroy                = var.spn_main_instance.force_destroy

  databases = {
    "consumer-db" = {
      name                     = var.spn_main_instance_consumer_db.name
      version_retention_period = var.spn_main_instance_consumer_db.version_retention_period
      encryption_config        = var.spn_main_instance_consumer_db.encryption_config
      database_dialect         = var.spn_main_instance_consumer_db.database_dialect
      enable_drop_protection   = var.spn_main_instance_consumer_db.enable_drop_protection
      deletion_protection      = var.spn_main_instance_consumer_db.deletion_protection
      default_time_zone        = var.spn_main_instance_consumer_db.default_time_zone
    }
  }
}

module "spn_main_instance_consumer_db_backup" {
  source                      = "git::https://github.com/GoogleCloudPlatform/terraform-google-cloud-spanner.git//modules/schedule_spanner_backup?ref=v1.2.1"
  project_id                  = var.project_id
  instance_name               = module.spn_main_instance.spanner_instance_name
  database_name               = module.spn_main_instance.database_names["consumer-db"]
  backup_schedule_name        = "${local.resource_name_prefix_global}-spn-main-instance-bkp-schedule"
  retention_duration          = var.spn_main_instance_consumer_db_backup.retention_duration
  cron_spec_text              = var.spn_main_instance_consumer_db_backup.cron_spec_text
  use_full_backup_spec        = var.spn_main_instance_consumer_db_backup.use_full_backup_spec
  use_incremental_backup_spec = var.spn_main_instance_consumer_db_backup.use_incremental_backup_spec
}

# [ Marketing API Edge START ]
# Reserved External IP - ip-marketing-api-edge
module "ip_marketing_api_edge" {
  source       = "git::https://github.com/terraform-google-modules/terraform-google-address.git?ref=v5.0.0"
  project_id   = var.mgmt_project_id
  names        = ["${local.resource_name_prefix_global}-ip-marketing-api-edge"]
  address_type = "EXTERNAL"
  global       = true
  region       = ""
}

# Cloud Armor - ca-marketing-api-security
module "ca_marketing_api_security" {
  source              = "git::https://github.com/GoogleCloudPlatform/terraform-google-cloud-armor.git?ref=v7.0.0"
  project_id          = var.project_id
  name                = "${local.resource_name_prefix_global}-ca-marketing-api-security"
}

# Certificate Manager - Marketing API Edge (DNS auth + managed cert + certificate map)
module "cert_manager_marketing_api_edge" {
  source     = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/certificate-manager?ref=v52.0.0"
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
      "${local.resource_name_prefix_global}-cme-wildcard" = {
        hostname     = "*.${var.wildcard_domain}"
        certificates = ["${local.resource_name_prefix_global}-gmc-wildcard"]
      }
    }
  }
}

# Global External Application Load Balancer - lb-marketing-api-edge (Cloud Foundation Fabric)
module "lb_marketing_api_edge" {
  count               = var.create_lb_marketing_api_edge ? 1 : 0
  source              = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-lb-app-ext?ref=v52.0.0"
  project_id          = var.mgmt_project_id
  name                = "${local.resource_name_prefix_global}-lb-marketing-api-edge"
  use_classic_version = false
  protocol            = "HTTPS"

  forwarding_rules_config = {
    "" = { address = module.ip_marketing_api_edge.self_links[0] }
  }

  https_proxy_config = {
    certificate_map = "//certificatemanager.googleapis.com/${module.cert_manager_marketing_api_edge.map_id}"
  }

  neg_configs = {
    for k, svc in local.marketing_api_edge_serverless_backend_services :
    k => {
      cloudrun = {
        region         = local.region["PRIMARY"]
        target_service = { name = format("%s-run-%s", local.resource_name_prefix_global, svc.name) }
      }
    }
  }

  backend_service_configs = {
    for k, svc in local.marketing_api_edge_serverless_backend_services :
    k => {
      project_id      = var.project_id
      protocol        = "HTTP"
      security_policy = svc.security_policy
      log_sample_rate = 1.0
      health_checks   = []
      backends        = [{ backend = k }]
    }
  }

  urlmap_config = {
    default_service = local.marketing_api_edge_path_matchers["api-paths"].default_service
    host_rules = [
      { hosts = ["*"], path_matcher = "api-paths" }
    ]
    path_matchers = local.marketing_api_edge_path_matchers
  }
}

# HTTPS redirect (HTTP port 80 → HTTPS)
resource "google_compute_url_map" "marketing_api_edge_https_redirect" {
  count   = var.create_lb_marketing_api_edge ? 1 : 0
  project = var.mgmt_project_id
  name    = "${local.resource_name_prefix_global}-lb-marketing-api-edge-https-redirect"
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "marketing_api_edge" {
  count   = var.create_lb_marketing_api_edge ? 1 : 0
  project = var.mgmt_project_id
  name    = "${local.resource_name_prefix_global}-lb-marketing-api-edge-http-proxy"
  url_map = google_compute_url_map.marketing_api_edge_https_redirect[0].id
}

resource "google_compute_global_forwarding_rule" "marketing_api_edge_http" {
  count                 = var.create_lb_marketing_api_edge ? 1 : 0
  project               = var.mgmt_project_id
  name                  = "${local.resource_name_prefix_global}-lb-marketing-api-edge-http"
  ip_address            = module.ip_marketing_api_edge.self_links[0]
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.marketing_api_edge[0].id
}
# [ Marketing API Edge END ]

# TODO: CLEANUP - Unused module, no downstream references to this Cloud Armor policy
# Cloud Armor - ca-message-api-security
module "ca_message_api_security" {
  source              = "git::https://github.com/GoogleCloudPlatform/terraform-google-cloud-armor.git?ref=v7.0.0"
  project_id          = var.project_id
  name                = "${local.resource_name_prefix_global}-ca-message-api-security"
}

# Cloud Armor - ca-internal-api-security
module "internal_api_security" {
  source              = "git::https://github.com/GoogleCloudPlatform/terraform-google-cloud-armor.git?ref=v7.0.0"
  project_id          = var.project_id
  name                = "${local.resource_name_prefix_global}-internal-api-security"
}

# Cloud Armor - ca-privacy-api-security
module "privacy_api_security" {
  source              = "git::https://github.com/GoogleCloudPlatform/terraform-google-cloud-armor.git?ref=v7.0.0"
  project_id          = var.project_id
  name                = "${local.resource_name_prefix_global}-privacy-api-security"
}

# Cloud Armor - ca-prospect-api-security
module "prospect_api_security" {
  source              = "git::https://github.com/GoogleCloudPlatform/terraform-google-cloud-armor.git?ref=v7.0.0"
  project_id          = var.project_id
  name                = "${local.resource_name_prefix_global}-prospect-api-security"
}

# [ Dedicated API Edge START ]
# Reserved IP - dedicated-api-edge
module "ip_dedicated_api_edge" {
  source       = "git::https://github.com/terraform-google-modules/terraform-google-address.git?ref=v5.0.0"
  project_id   = var.project_id
  names        = ["${local.resource_name_prefix_global}-ip-dedicated-api-edge"]
  address_type = "EXTERNAL"
  global       = true
  region       = ""
}

# Cloud Armor - ca-aad-b2c-api-security
module "ca_aad_b2c_api_security" {
  source              = "git::https://github.com/GoogleCloudPlatform/terraform-google-cloud-armor.git?ref=v7.0.0"
  project_id          = var.project_id
  name                = "${local.resource_name_prefix_global}-ca-aad-b2c-api-security"
}

# Certificate Manager - Dedicated API Edge (DNS auths + managed certs + certificate map)
module "cert_manager_dedicated_api_edge" {
  source     = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/certificate-manager?ref=v52.0.0"
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
      "${local.resource_name_prefix_global}-cme-wildcard" = {
        hostname     = "*.${var.wildcard_domain}"
        certificates = ["${local.resource_name_prefix_global}-gmc-wildcard"]
      }
      "${local.resource_name_prefix_global}-cme-prospect" = {
        hostname     = "*.${var.prospect_domain}"
        certificates = ["${local.resource_name_prefix_global}-gmc-prospect"]
      }
    }
  }
}

# Global External Application Load Balancer - dedicated-api-edge (Cloud Foundation Fabric)
module "lb_dedicated_api_edge" {
  count               = var.create_lb_dedicated_api_edge ? 1 : 0
  source              = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-lb-app-ext?ref=v52.0.0"
  project_id          = var.project_id
  name                = "${local.resource_name_prefix_global}-lb-dedicated-api-edge"
  use_classic_version = false
  protocol            = "HTTPS"

  forwarding_rules_config = {
    "" = { address = module.ip_dedicated_api_edge.self_links[0] }
  }

  https_proxy_config = {
    certificate_map = "//certificatemanager.googleapis.com/${module.cert_manager_dedicated_api_edge.map_id}"
  }

  neg_configs = {
    for k, svc in local.dedicated_api_edge_serverless_backend_services :
    k => {
      cloudrun = {
        region         = local.region["PRIMARY"]
        target_service = { name = format("%s-run-%s", local.resource_name_prefix_global, svc.name) }
      }
    }
  }

  backend_service_configs = {
    for k, svc in local.dedicated_api_edge_serverless_backend_services :
    k => {
      project_id      = var.project_id
      protocol        = "HTTP"
      security_policy = svc.security_policy
      log_sample_rate = 1.0
      health_checks   = []
      backends        = [{ backend = k }]
      iap_config      = try(svc.iap_config, null) != null ? {} : null
    }
  }

  backend_buckets_config = {
    gcs = {
      bucket_name = module.gcs_exp_configs.names_list[0]
      enable_cdn  = true
      cdn_policy = {
        cache_mode  = "CACHE_ALL_STATIC"
        default_ttl = 3600
        max_ttl     = 86400
      }
    }
  }

  urlmap_config = {
    default_service = local.dedicated_api_edge_path_matchers["api-paths"].default_service
    host_rules = [
      { hosts = ["*.${var.prospect_domain}"], path_matcher = "prospect-services-paths" },
      { hosts = ["${var.internal_services_hostname}.${var.wildcard_domain}"], path_matcher = "internal-services-paths" },
      { hosts = ["${var.aadb2c_services_hostname}.${var.wildcard_domain}"], path_matcher = "aadb2c-services-paths" },
      { hosts = ["*"], path_matcher = "api-paths" }
    ]
    path_matchers = local.dedicated_api_edge_path_matchers
  }
}

# HTTPS redirect (HTTP port 80 → HTTPS)
resource "google_compute_url_map" "dedicated_api_edge_https_redirect" {
  count   = var.create_lb_dedicated_api_edge ? 1 : 0
  project = var.project_id
  name    = "${local.resource_name_prefix_global}-lb-dedicated-api-edge-https-redirect"
  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "dedicated_api_edge" {
  count   = var.create_lb_dedicated_api_edge ? 1 : 0
  project = var.project_id
  name    = "${local.resource_name_prefix_global}-lb-dedicated-api-edge-http-proxy"
  url_map = google_compute_url_map.dedicated_api_edge_https_redirect[0].id
}

resource "google_compute_global_forwarding_rule" "dedicated_api_edge_http" {
  count                 = var.create_lb_dedicated_api_edge ? 1 : 0
  project               = var.project_id
  name                  = "${local.resource_name_prefix_global}-lb-dedicated-api-edge-http"
  ip_address            = module.ip_dedicated_api_edge.self_links[0]
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.dedicated_api_edge[0].id
}
# [ Dedicated API Edge END ]

# Internal Address
module "ip_marketing_ilb_primary" {
  count        = contains(["alpha", "beta", "gamma", "prod"], lower(var.environment)) ? 1 : 0
  source       = "git::https://github.com/terraform-google-modules/terraform-google-address.git?ref=v5.0.0"
  project_id   = var.project_id
  names        = ["${local.resource_name_prefix_primary}-ip-marketing"]
  region       = local.region["PRIMARY"]
  addresses    = ["10.0.8.150"]
  subnetwork   = data.google_compute_subnetwork.ilb_subnet_primary[0].self_link
}

module "ip_marketing_ilb_secondary" {
  count        = contains(["gamma", "prod"], lower(var.environment)) ? 1 : 0
  source       = "git::https://github.com/terraform-google-modules/terraform-google-address.git?ref=v5.0.0"
  project_id   = var.project_id
  names        = ["${local.resource_name_prefix_secondary}-ip-marketing"]
  region       = local.region["SECONDARY"]
  addresses    = ["10.0.8.250"]
  subnetwork   = data.google_compute_subnetwork.ilb_subnet_secondary[0].self_link
}

# [PRIMARY START]

# Valkey Memorystore
module "vkey_main_primary" {
  count                         = local.deploy_primary ? 1 : 0
  source                        = "git::https://github.com/terraform-google-modules/terraform-google-memorystore.git//modules/valkey?ref=v16.0.0"
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

data "google_cloud_run_v2_service" "frontend_get_consumer_primary" {
  count    = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  project  = var.project_id
  location = local.region["PRIMARY"]
  name     = "${local.resource_name_prefix_primary}-run-frontend-get-consumer"
}

data "google_cloud_run_v2_service" "message_event_processor_primary" {
  count    = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  project  = var.project_id
  location = local.region["PRIMARY"]
  name     = "${local.resource_name_prefix_primary}-run-message-event-processor"
}

data "google_cloud_run_v2_service" "enrichment_get_data_primary" {
  count    = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  project  = var.project_id
  location = local.region["PRIMARY"]
  name     = "${local.resource_name_prefix_primary}-run-enrichment-get-data"
}

data "google_cloud_run_v2_service" "enrichment_put_data_primary" {
  count    = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  project  = var.project_id
  location = local.region["PRIMARY"]
  name     = "${local.resource_name_prefix_primary}-run-enrichment-put-data"
}

# Internal Application LB + NEGs + Service Attachment (Cloud Foundation Fabric)
module "lb_marketing_primary" {
  count      = local.deploy_primary && var.create_lb_marketing_primary ? 1 : 0
  source     = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-lb-app-int?ref=v52.0.0"
  project_id = var.project_id
  region     = local.region["PRIMARY"]
  name       = "${local.resource_name_prefix_primary}-lb-marketing"
  address    = module.ip_marketing_ilb_primary[0].self_links[0]

  vpc_config = {
    network    = data.google_compute_network.network.self_link
    subnetwork = data.google_compute_subnetwork.ilb_subnet_primary[0].self_link
  }

  neg_configs = {
    frontend-update-consumer = {
      cloudrun = {
        region         = local.region["PRIMARY"]
        target_service = { name = data.google_cloud_run_v2_service.frontend_update_consumer_primary[0].name }
      }
    }
    frontend-get-consumer = {
      cloudrun = {
        region         = local.region["PRIMARY"]
        target_service = { name = data.google_cloud_run_v2_service.frontend_get_consumer_primary[0].name }
      }
    }
    message-event-processor = {
      cloudrun = {
        region         = local.region["PRIMARY"]
        target_service = { name = data.google_cloud_run_v2_service.message_event_processor_primary[0].name }
      }
    }
    enrichment-get-data = {
      cloudrun = {
        region         = local.region["PRIMARY"]
        target_service = { name = data.google_cloud_run_v2_service.enrichment_get_data_primary[0].name }
      }
    }
    enrichment-put-data = {
      cloudrun = {
        region         = local.region["PRIMARY"]
        target_service = { name = data.google_cloud_run_v2_service.enrichment_put_data_primary[0].name }
      }
    }
  }

  backend_service_configs = {
    frontend-update-consumer = {
      backends      = [{ group = "frontend-update-consumer" }]
      health_checks = []
    }
    frontend-get-consumer = {
      backends      = [{ group = "frontend-get-consumer" }]
      health_checks = []
    }
    message-event-processor = {
      backends      = [{ group = "message-event-processor" }]
      health_checks = []
    }
    enrichment-get-data = {
      backends      = [{ group = "enrichment-get-data" }]
      health_checks = []
    }
    enrichment-put-data = {
      backends      = [{ group = "enrichment-put-data" }]
      health_checks = []
    }
  }

  urlmap_config = {
    default_service = "frontend-update-consumer"
    host_rules = [
      { hosts = ["*"], path_matcher = "api-paths" }
    ]
    path_matchers = {
      "api-paths" = {
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
    nat_subnets          = [data.google_compute_subnetwork.psc_subnet_primary[0].id]
    automatic_connection = true
  }
}
# [ Internal Application LB - Marketing END ]
# [PRIMARY END]

# [SECONDARY START]
module "vkey_main_secondary" {
  source                        = "git::https://github.com/terraform-google-modules/terraform-google-memorystore.git//modules/valkey?ref=v16.0.0"
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

data "google_cloud_run_v2_service" "frontend_get_consumer_secondary" {
  count    = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  project  = var.project_id
  location = local.region["SECONDARY"]
  name     = "${local.resource_name_prefix_secondary}-run-frontend-get-consumer"
}

data "google_cloud_run_v2_service" "message_event_processor_secondary" {
  count    = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  project  = var.project_id
  location = local.region["SECONDARY"]
  name     = "${local.resource_name_prefix_secondary}-run-message-event-processor"
}

data "google_cloud_run_v2_service" "enrichment_get_data_secondary" {
  count    = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  project  = var.project_id
  location = local.region["SECONDARY"]
  name     = "${local.resource_name_prefix_secondary}-run-enrichment-get-data"
}

data "google_cloud_run_v2_service" "enrichment_put_data_secondary" {
  count    = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  project  = var.project_id
  location = local.region["SECONDARY"]
  name     = "${local.resource_name_prefix_secondary}-run-enrichment-put-data"
}

# Internal Application LB + NEGs + Service Attachment (Cloud Foundation Fabric)
module "lb_marketing_secondary" {
  count      = local.deploy_secondary && var.create_lb_marketing_secondary ? 1 : 0
  source     = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric.git//modules/net-lb-app-int?ref=v52.0.0"
  project_id = var.project_id
  region     = local.region["SECONDARY"]
  name       = "${local.resource_name_prefix_secondary}-lb-marketing"
  address    = module.ip_marketing_ilb_secondary[0].self_links[0]

  vpc_config = {
    network    = data.google_compute_network.network.self_link
    subnetwork = data.google_compute_subnetwork.ilb_subnet_secondary[0].self_link
  }

  neg_configs = {
    frontend-update-consumer = {
      cloudrun = {
        region         = local.region["SECONDARY"]
        target_service = { name = data.google_cloud_run_v2_service.frontend_update_consumer_secondary[0].name }
      }
    }
    frontend-get-consumer = {
      cloudrun = {
        region         = local.region["SECONDARY"]
        target_service = { name = data.google_cloud_run_v2_service.frontend_get_consumer_secondary[0].name }
      }
    }
    message-event-processor = {
      cloudrun = {
        region         = local.region["SECONDARY"]
        target_service = { name = data.google_cloud_run_v2_service.message_event_processor_secondary[0].name }
      }
    }
    enrichment-get-data = {
      cloudrun = {
        region         = local.region["SECONDARY"]
        target_service = { name = data.google_cloud_run_v2_service.enrichment_get_data_secondary[0].name }
      }
    }
    enrichment-put-data = {
      cloudrun = {
        region         = local.region["SECONDARY"]
        target_service = { name = data.google_cloud_run_v2_service.enrichment_put_data_secondary[0].name }
      }
    }
  }

  backend_service_configs = {
    frontend-update-consumer = {
      backends      = [{ group = "frontend-update-consumer" }]
      health_checks = []
    }
    frontend-get-consumer = {
      backends      = [{ group = "frontend-get-consumer" }]
      health_checks = []
    }
    message-event-processor = {
      backends      = [{ group = "message-event-processor" }]
      health_checks = []
    }
    enrichment-get-data = {
      backends      = [{ group = "enrichment-get-data" }]
      health_checks = []
    }
    enrichment-put-data = {
      backends      = [{ group = "enrichment-put-data" }]
      health_checks = []
    }
  }

  urlmap_config = {
    default_service = "frontend-update-consumer"
    host_rules = [
      { hosts = ["*"], path_matcher = "api-paths" }
    ]
    path_matchers = {
      "api-paths" = {
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
    nat_subnets          = [data.google_compute_subnetwork.psc_subnet_secondary[0].id]
    automatic_connection = true
  }
}
# [ Internal Application LB - Marketing END ]

# [SECONDARY END]

# [Core Infrastructure END]
