# terraform/week8/outputs.tf
# ─────────────────────────────────────────────────────────────────────────────
# Outputs are printed after terraform apply and stored in the state file.
#
# After apply, get the service URL:
#   terraform output service_url
#
# Or open it directly:
#   open $(terraform output -raw service_url)
# ─────────────────────────────────────────────────────────────────────────────

output "service_url" {
  description = "Public HTTPS URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.flask_app.uri
  # Format: https://cis410-flask-app-HASH-uc.a.run.app
}

output "service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_v2_service.flask_app.name
}

output "latest_revision" {
  description = "Name of the most recently deployed revision"
  value       = google_cloud_run_v2_service.flask_app.latest_created_revision
}
