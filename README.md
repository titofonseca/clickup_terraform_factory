## ClickUp as Catalog, Terraform as Assembly Line (Minimal Example)

### What is this?
This repository demonstrates a minimal, end-to-end pattern where ClickUp acts as a living catalog and Terraform acts as the assembly line. The flow is intentionally simple:

- Module 1 reads ClickUp (Space → List → Tasks) via a tiny Python script and outputs active clients with `name`, `env`, `region`.
- Module 2 creates one BigQuery dataset per active client using the convention `{name}_{env}_{region}` and uses `region` as the BigQuery location.

The result is idempotent: on each run, Terraform reconciles the declared state (tasks marked as sync in ClickUp) with what exists in BigQuery.

### How it works (logic)
1. Read ClickUp tasks from a specific Space/List.
2. Consider as active any task whose status contains `sync` (case-insensitive).
3. Extract custom fields `env` and `region` from each active task.
4. Build dataset names as `{name}_{env}_{region}` (sanitized to valid BigQuery dataset IDs).
5. Create or ensure those datasets exist in BigQuery, in the specified `region`.

### Prerequisites
- Terraform >= 1.5
- Python 3
- Google Cloud credentials (e.g., `gcloud auth application-default login`)

### ClickUp prerequisites
- Your target List must contain tasks representing clients.
- Mark tasks to be included by setting their status to contain `sync` (e.g., `sync`, `sync (full)`, etc.).
- Ensure custom fields exist and are named `env` and `region` (case-insensitive match on field names).

### Configure variables
1. Copy the example vars:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Fill `terraform.tfvars` with:
   - `gcp_project_id`
   - `clickup_api_token`
   - `clickup_space_id`
   - `clickup_list_id`

### Run
```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### Quickstart (full flow)
```bash
# Authenticate to Google Cloud (once per machine/account)
gcloud init
gcloud auth application-default login

# Configure variables
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your values

# Run Terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### Outputs
- `active_clients`: the list of active clients discovered with their `env` and `region`.
- `created_dataset_ids`: the dataset IDs created/ensured in BigQuery.

### Clean up
```bash
terraform destroy -auto-approve
```

### Learn more / say hi
Find me on the Medium article: https://medium.com/@titoamfonseca/clickup-as-a-living-catalog-terraform-as-the-assembly-line-77ec43fadbd5


