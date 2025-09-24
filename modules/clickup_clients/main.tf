// Module 1: Fetch active clients from ClickUp (Space → List → Tasks)

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

data "external" "clickup_clients" {
  program = [
    "python3",
    "${path.module}/scripts/fetch_clickup_clients.py",
  ]

  query = {
    api_token = var.clickup_api_token
    space_id  = var.space_id
    list_id   = var.list_id
  }
}

locals {
  // Expected schema from the script
  // {
  //   "clients": [{"name": "clientA", "env": "prod", "region": "EU"}, ...]
  // }
  raw = data.external.clickup_clients.result
  clients = try(jsondecode(lookup(local.raw, "clients", "[]")), [])
}

