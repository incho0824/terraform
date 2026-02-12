
variable "cloud_foundation_fabric_version" {
  description = "Version (git ref) for GoogleCloudPlatform/cloud-foundation-fabric modules"
  type        = string
  default     = "v45.0.0"
}

variable "cloud_spanner_module_version" {
  description = "Version (git ref) for GoogleCloudPlatform/terraform-google-cloud-spanner modules"
  type        = string
  default     = "v1.2.1"
}

variable "cloud_armor_module_version" {
  description = "Version (git ref) for GoogleCloudPlatform/terraform-google-cloud-armor module"
  type        = string
  default     = "v7.0.0"
}

variable "cloud_storage_module_version" {
  description = "Version (git ref) for terraform-google-modules/terraform-google-cloud-storage modules"
  type        = string
  default     = "v11.0.0"
}

variable "memorystore_module_version" {
  description = "Version (git ref) for terraform-google-modules/terraform-google-memorystore modules"
  type        = string
  default     = "v16.0.0"
}

variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "network_project_id" {
  type        = string
  description = "Shared VPC Host Project ID"
}

variable "mgmt_project_id" {
  type        = string
  description = "Management Project ID"
}

variable "network" {
  type        = string
  description = "Shared VPC Network"
}

variable "ilb_subnet_primary" {
  type        = string
  description = "Primary ILB Subnet created in Shared VPC Network"
}

variable "ilb_subnet_secondary" {
  type        = string
  description = "Secondary ILB Subnet created in Shared VPC Network"
}

variable "psc_subnet_primary" {
  type        = string
  description = "Primary PSC Subnet created in Shared VPC Network"
}

variable "psc_subnet_secondary" {
  type        = string
  description = "Secondary PSC Subnet created in Shared VPC Network"
}

variable "state_bucket" {
  type        = string
  description = "Name of Terraform State Bucket created as part of bootstrap"
}

variable "geo" {
  description = "The Geography in which this resource is created in. Values: apac, emea, product, latam, na"
  type        = string
}

variable "app_code" {
  description = "Short name of the application. Eg. cds"
  type        = string
}

variable "environment" {
  description = "Deployment environment name. Values: alpha, beta, gamma, prod"
  type        = string
}

variable "deploy_primary" {
  description = "Whether to create primary region specific resources"
  type        = bool
}

variable "deploy_secondary" {
  description = "Whether to create secondary region specific resources"
  type        = bool
  default     = null
}

variable "create_lb_marketing_primary" {
  description = "Whether to create the internal application load balancer for marketing"
  type        = bool
}

variable "create_lb_marketing_secondary" {
  description = "Whether to create the internal application load balancer for marketing"
  type        = bool
}

variable "create_lb_dedicated_api_edge" {
  description = "Whether to create the Dedicated API Edge Global External Application Load Balancer"
  type        = bool
}

variable "create_lb_marketing_api_edge" {
  description = "Whether to create the MArketing API Edge Global External Application Load Balancer"
  type        = bool
}

variable "sm_vkey_creds_secret_data" {
  description = "Valkey Creds Secret Data"
  sensitive   = true
  type        = string
}

variable "sm_fraud_configs_secret_data" {
  description = "Fraud Config Secret Data"
  sensitive   = true
  type        = string
}

variable "sm_gateway_creds_secret_data" {
  description = "Gateway Creds Secret Data"
  sensitive   = true
  type        = string
}

variable "sm_meta_access_token_secret_data" {
  description = "Meta Access Token Secret Data"
  sensitive   = true
  type        = string
}

variable "sm_meta_verify_token_secret_data" {
  description = "Meta verify Token Secret Data"
  sensitive   = true
  type        = string
}

variable "sm_recaptcha_config_secret_data" {
  description = "Recaptcha config Secret Data"
  sensitive   = true
  type        = string
}

variable "sm_prospect_ingestion_oauth_parameter_secret_data" {
  description = "prospect ingestion Oauth parameter Secret Data"
  sensitive   = true
  type        = string
}

variable "spn_main_instance" {
  description = <<EOT
  An object containing optional configuration parameters for creating a Google Cloud Spanner instance.
  Each attribute maps to a specific configuration value from the original variables.tf. All attributes in this object are optional and can be set to null if not used.
  Attributes:
  - instance_config: Instance configuration name (region placement & replication).
  - edition: Edition of the Spanner instance (nullable).
  - num_nodes: Number of allocated nodes (nullable, mutually exclusive with processing_units and autoscaling_config unless instance_type=FREE_INSTANCE).
  - processing_units: Number of processing units (nullable).
  - instance_type: Type of instance (PROVISIONED or FREE_INSTANCE).
  - enable_autoscaling: Boolean to enable autoscaling.
  - min_processing_units: Minimum processing units for autoscaling (nullable).
  - max_processing_units: Maximum processing units for autoscaling (nullable).
  - high_priority_cpu_utilization_percent: Target high priority CPU utilization (nullable).
  - storage_utilization_percent: Target storage utilization (nullable).
  - default_backup_schedule_type: Default backup schedule type for new databases ("NONE" by default).
  - force_destroy: Boolean to force deletion of the instance and backups.
  EOT
  type = object({
    instance_config                       = string
    edition                               = optional(string)
    num_nodes                             = optional(number)
    processing_units                      = optional(number)
    instance_type                         = optional(string)
    enable_autoscaling                    = bool
    min_processing_units                  = optional(number)
    max_processing_units                  = optional(number)
    high_priority_cpu_utilization_percent = optional(number)
    storage_utilization_percent           = optional(number)
    default_backup_schedule_type          = optional(string, "NONE")
    force_destroy                         = optional(bool, false)
  })
}

variable "spn_main_instance_consumer_db_backup" {
  description = <<EOT
  An object containing optional configuration parameters for creating a backup schedule in Google Cloud Spanner.

  Attributes:
  - retention_duration: The duration for which the backup should be retained (string, RFC3339 duration format).
  - cron_spec_text: The CRON spec text defining the schedule.
  - use_full_backup_spec: Boolean indicating whether to use a full backup specification (default null).
  - use_incremental_backup_spec: Boolean indicating whether to use incremental backup specification (default null).
  EOT

  type = object({
    retention_duration          = string
    cron_spec_text              = string
    use_full_backup_spec        = optional(bool, null)
    use_incremental_backup_spec = optional(bool, null)
  })
}

variable "spn_main_instance_consumer_db" {
  description = <<EOT
  Configuration object for creating a Cloud Spanner database.

  Attributes:
  - name: (Required) Unique database name. Pattern: [a-z][-_a-z0-9]*[a-z0-9].
  - version_retention_period: (Optional) Retention period for the database, 1h-7d (e.g. "1d", "1440m", "86400s").
  - encryption_config: (Optional) Encryption settings:
      - kms_key_name: (Optional) Fully qualified resource name of the KMS key.
      - kms_key_names: (Optional) List of fully qualified KMS keys.
  - database_dialect: (Optional) GOOGLE_STANDARD_SQL or POSTGRESQL.
  - enable_drop_protection: (Optional) Enable drop protection.
  - ddl: (Optional) List of DDL statements to apply at create time.
  - deletion_protection: (Optional) Prevent Terraform from deleting the database.
  - default_time_zone: (Optional) Default TZ database name. 
  EOT

  type = object({
    name                     = string
    version_retention_period = optional(string)
    encryption_config = optional(object({
      kms_key_name  = optional(string)
      kms_key_names = optional(list(string))
    }), null)
    database_dialect       = optional(string, "GOOGLE_STANDARD_SQL")
    enable_drop_protection = optional(bool)
    ddl                    = optional(list(string), [])
    deletion_protection    = optional(bool)
    default_time_zone      = optional(string)
  })
}

variable "fs_main_database" {
  description = <<EOT
  Configuration object for Firestore database settings excluding project_id, name, and location.

  Attributes:
  - location: The location in which the Firesotre Database is created.
  - database_type: (Required) The database type used to create the Firestore Database.
  - database_edition: (Optional) The edition of the database (default: null).
  - concurrency_mode: (Optional) Concurrency control mode to use for the database.
  - app_engine_integration_mode: (Optional) ENABLED or DISABLED.
  - point_in_time_recovery_enablement: (Optional) Point-in-time recovery enabled state.
  - delete_protection_state: (Optional) Whether deletion protection is enabled.
  - deletion_policy: (Optional) Policy enforced when destroyed via Terraform.
  - kms_key_name: (Optional) Customer-managed Encryption Key (CMEK) resource ID.
  EOT

  type = object({
    location                          = string
    database_type                     = string
    database_edition                  = optional(string)
    concurrency_mode                  = optional(string)
    app_engine_integration_mode       = optional(string)
    point_in_time_recovery_enablement = optional(string)
    delete_protection_state           = optional(string)
    deletion_policy                   = optional(string)
    kms_key_name                      = optional(string)
  })
}

variable "vkey_main_primary" {
  description = "Valkey instance Config"
  type = object({
    engine_version                = string
    shard_count                   = number
    zone_distribution_config_mode = string
    authorization_mode            = string
    deletion_protection_enabled   = bool
  })
}

variable "vkey_main_secondary" {
  description = "Valkey instance Config"
  type = object({
    engine_version                = string
    shard_count                   = number
    zone_distribution_config_mode = string
    authorization_mode            = string
    deletion_protection_enabled   = bool
  })
}

variable "gcs_exp_configs" {
  description = "GCS Bucket Config"
  type = object({
    location                    = string
    public_access_prevention    = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
  })
}

variable "gcs_prospect_configs" {
  description = "GCS Bucket Config"
  type = object({
    location                    = string
    public_access_prevention    = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
  })
}

variable "gcs_prospect_dropzone" {
  description = "GCS Bucket Config"
  type = object({
    location                    = string
    public_access_prevention    = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
  })
}

variable "gcs_privacy_configs" {
  description = "GCS Bucket Config"
  type = object({
    location                    = string
    public_access_prevention    = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
  })
}

variable "gcs_privacy_consumer_archive" {
  description = "GCS Bucket Config"
  type = object({
    location                    = string
    public_access_prevention    = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
  })
}

variable "gcs_aadb2c_event_dropzone" {
  description = "GCS Bucket Config"
  type = object({
    location                    = string
    public_access_prevention    = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
  })
}

variable "gcs_exp_templates" {
  description = "GCS Bucket Config"
  type = object({
    location                    = string
    public_access_prevention    = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
  })
}

variable "gcs_aad_b2c_component_cdn" {
  description = "GCS Bucket Config"
  type = object({
    location                    = string
    public_access_prevention    = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
  })
}

variable "gcs_aad_b2c_component_demo" {
  description = "GCS Bucket Config"
  type = object({
    location                    = string
    public_access_prevention    = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
  })
}

variable "gcs_aad_b2c_component_account" {
  description = "GCS Bucket Config"
  type = object({
    location                    = string
    public_access_prevention    = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
  })
}

variable "gcs_consumer_gamv2_demo_site" {
  description = "GCS Bucket Config"
  type = object({
    location                    = string
    public_access_prevention    = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
  })
}

variable "gcs_processor_configs" {
  description = "GCS Bucket Config"
  type = object({
    location                    = string
    public_access_prevention    = string
    uniform_bucket_level_access = bool
    force_destroy               = bool
  })
}

variable "wildcard_domain" {
  type        = string
  description = "Wildcard domain"
}

variable "prospect_domain" {
  type        = string
  description = "Prospect domain"
}

variable "internal_services_hostname" {
  type        = string
  description = "Internal Services Hostname"
}


variable "aadb2c_services_hostname" {
  type        = string
  description = "AADB2C Services Hostname"
}

variable "region_by_geo_type" {
  description = "Mapping of geo type to primary and secondary regions"
  type = map(object({
    PRIMARY   = string
    SECONDARY = string
  }))

  default = {
    PRODUCT = {
      PRIMARY   = "us-central1"
      SECONDARY = "us-east1"
    }
  }
}

variable "zone_by_geo_type" {
  description = "Mapping of geo type to primary and secondary zones"
  type = map(object({
    PRIMARY   = string
    SECONDARY = string
  }))

  default = {
    PRODUCT = {
      PRIMARY   = "us-central1-a"
      SECONDARY = "us-east1-b"
    }
  }
}
