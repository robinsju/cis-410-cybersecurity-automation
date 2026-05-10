# terraform/week6/outputs.tf
# ─────────────────────────────────────────────────────────────────────────────
# Values printed after terraform apply. Both buckets shown.
# ─────────────────────────────────────────────────────────────────────────────

output "tf_state_bucket_name" {
  description = "Terraform state bucket name"
  value       = google_storage_bucket.tf_state.name
}

output "tf_state_bucket_url" {
  description = "GCS URL — used as backend in Week 7"
  value       = google_storage_bucket.tf_state.url
}

output "logs_bucket_name" {
  description = "Logs bucket name"
  value       = google_storage_bucket.tf_state.name
}

output "logs_bucket_url" {
  description = "GCS URL of the logs bucket"
  value       = google_storage_bucket.tf_state.url
}

output "project_id" {
  description = "GCP project this was deployed to"
  value       = var.project_id
}
