output "active_clients" {
  description = "Active clients discovered in ClickUp including env and region"
  value       = module.clickup_clients.active_clients
}

output "created_dataset_ids" {
  description = "Dataset IDs created or ensured to exist"
  value       = module.bq_datasets.dataset_ids
}


