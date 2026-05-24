# terraform/week8/variables.tf
# ─────────────────────────────────────────────────────────────────────────────
# Root module variable declarations for Week 8.
#
# Set values in terraform.tfvars for local/Cloud Shell runs.
# In GitHub Actions, values are passed as TF_VAR_ environment variables.
# ─────────────────────────────────────────────────────────────────────────────

variable "project_id" {
  description = "Your GCP Project ID (e.g. cis410-ed)"
  type        = string
  # Find it: gcloud config get-value project
}

variable "region" {
  description = "GCP region for Cloud Run and Artifact Registry"
  type        = string
  default     = "us-central1"
}

variable "container_image" {
  description = "Full Artifact Registry image path with commit SHA tag"
  type        = string
  # Format: us-central1-docker.pkg.dev/PROJECT_ID/cis410-app/flask-app:COMMIT_SHA
  #
  # Get it in Cloud Shell after running gcloud builds submit:
  #   echo $IMAGE_PATH
  #
  # Example:
  #   us-central1-docker.pkg.dev/cis410-ed/cis410-app/flask-app:a3f9b12
  #
  # NEVER use :latest — always use the commit SHA tag so you know
  # exactly which version of the code is running.
}
