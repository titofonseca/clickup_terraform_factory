// Module 2: Create BigQuery datasets for active clients

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

locals {
  dataset_specs = [for c in var.clients : {
    // basic sanitization: lowercase and replace spaces/hyphens with underscores
    name   = lower(replace(replace("${c.name}_${c.env}_${c.region}", " ", "_"), "-", "_"))
    region = c.region
  }]
}

resource "google_bigquery_dataset" "client_dataset" {
  for_each                  = { for d in local.dataset_specs : d.name => d }
  dataset_id                = each.key
  location                  = each.value.region
  delete_contents_on_destroy = false
}

