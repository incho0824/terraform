# GCP Consumer Stack (Bootstrap · Ingress · Network)

This repository wires together three Terraform modules to bootstrap a GCP project, set up a public ingress to a Cloud Run service, and provision networks.

---

## Prerequisites

- Terraform ≥ 1.6
- Google provider ≥ 5.x
- A GCP project you can administer
- Auth configured locally (e.g., `gcloud auth application-default login`)

Required APIs typically include (depending on your modules): Cloud Run, Cloud Build, Compute Engine, Service Networking, IAM.

---

## Quick Start

Create a `main.tf` in the repo root with the following (replace placeholder values):

```hcl
module "consumer_bootstrap" {
  source             = "./modules/consumer/bootstrap"
  project_id         = "my-project"
  region             = "us-central1"
  repository_id      = "my-repo"
  state_bucket_name  = "my-project-tf-state"
  service_account_id = "consumer-sa"

  # Optional:
  location          = "US"
  repository_format = "DOCKER"
}

module "consumer_ingress" {
  source                 = "./modules/consumer/ingress"
  project_id             = "my-project"
  region                 = "us-central1"
  bucket_name            = "static-bucket"
  location               = "US"
  cloud_run_service_name = "api-service"
  cloud_run_image        = "gcr.io/my-project/my-image"
  domain                 = "example.com"
  member                 = "allUsers"    # or another principal

  # Optional:
  api_path = "/api/*"

  # Optional mTLS configuration:
  # enable_mtls = true
  # client_ca   = file("ca.pem")
}

module "consumer_network" {
  source                      = "./modules/consumer/network"
  project_id                  = "my-project"
  region                      = "us-central1"
  external_proxy_network_name = "proxy-net"
  internal_only_network_name  = "internal-net"
  firehose_network_name       = "firehose-net"

  # Optional:
  external_proxy_subnet_cidr = "10.0.1.0/24"
  internal_only_subnet_cidr  = "10.0.2.0/24"
  firehose_subnet_cidr       = "10.0.3.0/24"
}
```

Then run:

```
terraform init
terraform plan
terraform apply
```
