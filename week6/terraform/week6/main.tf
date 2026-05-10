# Week 6 — First Terraform Configuration
# Creates a Google Cloud Storage bucket in your GCP project
terraform {
  required_version = ">= 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
provider "google" {
  project = var.project_id
  region  = var.region
}
# Google Cloud Storage bucket — used as Terraform state backend in Week 7
resource "google_storage_bucket" "tf_state" {
  name                        = "${var.project_id}-tfstate"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }
    action {
      type = "Delete"
    }
  }
}
