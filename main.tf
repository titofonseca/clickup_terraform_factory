// Root module: orchestrates ClickUp discovery and BigQuery dataset creation

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
}

module "clickup_clients" {
  source = "./modules/clickup_clients"

  clickup_api_token = var.clickup_api_token
  space_id          = var.clickup_space_id
  list_id           = var.clickup_list_id
}

module "bq_datasets" {
  source = "./modules/bq_datasets"

  clients = module.clickup_clients.active_clients
}


