// Root variables

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "clickup_api_token" {
  description = "ClickUp API token"
  type        = string
  sensitive   = true
}

variable "clickup_space_id" {
  description = "ClickUp Space ID"
  type        = string
}

variable "clickup_list_id" {
  description = "ClickUp List ID inside the Space"
  type        = string
}


