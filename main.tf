# terraform/week8/main.tf
# ─────────────────────────────────────────────────────────────────────────────
# CIS 410 — Week 8: Cloud Run Deployment
#
# Deploys the Flask app as a Cloud Run service connected to the
# Week 7 VPC. Reads VPC outputs from Week 7 remote state.
#
# BEFORE RUNNING:
#   1. Replace "cis410-yourname-xxxx-tfstate" with your actual bucket name
#      in BOTH the backend block AND the data block below
#   2. Confirm terraform/week7/ state exists:
#      gcloud storage ls gs://YOUR_BUCKET/terraform/week7/
#   3. Fill in terraform.tfvars with your project ID and image path
#   4. terraform init
#   5. terraform plan   (should show: 2 to add)
#   6. terraform apply  (type yes)
#
# RESOURCES CREATED:
#   google_cloud_run_v2_service          — the Cloud Run service
#   google_cloud_run_v2_service_iam_member — allows public internet access
# ─────────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.5"

  # ── Remote State Backend ──────────────────────────────────────────────────
  # Stores Week 8 state in the same GCS bucket as Week 7,
  # but in a separate prefix so the two states never conflict.
  #
  # State file location: gs://YOUR_BUCKET/terraform/week8/default.tfstate
  #
  # REPLACE: change cis410-yourname-xxxx-tfstate to your actual bucket name.
  backend "gcs" {
    bucket = "cis410-yourname-xxxx-tfstate"   # ← your bucket name
    prefix = "terraform/week8"
  }

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

# ── Read VPC outputs from Week 7 state ───────────────────────────────────────
# Instead of hardcoding vpc_name and subnet_name, this data source reads
# them directly from the state file that Week 7 terraform apply created.
#
# HOW IT WORKS:
#   Terraform reads gs://YOUR_BUCKET/terraform/week7/default.tfstate
#   and exposes its output values under data.terraform_remote_state.week7.outputs
#
# REFERENCE SYNTAX:
#   data.terraform_remote_state.week7.outputs.vpc_name
#   data.terraform_remote_state.week7.outputs.subnet_name
#
# IMPORTANT: The prefix here must exactly match the prefix used in Week 7's
# backend block. Check terraform/week7/main.tf to confirm.
#
# REPLACE: change cis410-yourname-xxxx-tfstate to your actual bucket name.
data "terraform_remote_state" "week7" {
  backend = "gcs"
  config = {
    bucket = "cis410-yourname-xxxx-tfstate"   # ← same bucket as above
    prefix = "terraform/week7"                 # ← must match Week 7 backend prefix exactly
  }
}

# ── Cloud Run Service ─────────────────────────────────────────────────────────
# Deploys the Flask container image as a serverless Cloud Run service.
#
# Cloud Run differences from on-premise Docker (Weeks 3-5):
#   - No SSH, no VM, no docker run command
#   - HTTPS is automatic — no certificate configuration needed
#   - Scales to zero when idle (min_instance_count = 0)
#   - Scales up automatically when traffic arrives
#   - Every deploy is a new immutable revision — easy rollback
resource "google_cloud_run_v2_service" "flask_app" {
  name     = "cis410-flask-app"
  location = var.region

  template {
    containers {
      # Full Artifact Registry image path including commit SHA tag.
      # Format: us-central1-docker.pkg.dev/PROJECT_ID/cis410-app/flask-app:COMMIT_SHA
      # Set in terraform.tfvars — do NOT commit that file.
      image = var.container_image

      # Flask app listens on port 5000
      ports {
        container_port = 5000
      }

      # Resource limits — sufficient for this course lab
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }

    scaling {
      min_instance_count = 0   # scale to zero when idle — no cost when unused
      max_instance_count = 3   # cap for lab environment
    }

    # ── VPC Connection ──────────────────────────────────────────────────────
    # Connects Cloud Run to the VPC and subnet created in Week 7.
    # Values come from the terraform_remote_state data source above.
    #
    # egress = "PRIVATE_RANGES_ONLY" means only traffic destined for
    # private IP ranges (10.x.x.x, 172.16.x.x, 192.168.x.x) goes through
    # the VPC. Public internet traffic goes directly — better performance.
    vpc_access {
      network_interfaces {
        network    = data.terraform_remote_state.week7.outputs.vpc_name
        subnetwork = data.terraform_remote_state.week7.outputs.subnet_name
      }
      egress = "PRIVATE_RANGES_ONLY"
    }
  }
}

# ── Public Access IAM Binding ─────────────────────────────────────────────────
# By default Cloud Run rejects all unauthenticated requests with a 403 error.
# This IAM binding grants the "run.invoker" role to "allUsers" — allowing
# anyone on the internet to call the service without authentication.
#
# For a production app you would remove this and use Cloud IAP or
# Firebase Auth instead. For this course lab, public access is required
# so the instructor can verify the service URL works.
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloud_run_v2_service.flask_app.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"   # allows anyone to call the service
}
