output "dataset_ids" {
  description = "Dataset IDs created or ensured to exist"
  value       = keys(google_bigquery_dataset.client_dataset)
}


