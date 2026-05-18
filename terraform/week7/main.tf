# terraform/week7/main.tf
# ────────────────────────────────────────────────────────────────────────
# Root module: declares remote state backend + calls networking module.
# ────────────────────────────────────────────────────────────────────────
terraform {
  required_version = ">= 1.6"
  # ── Remote State Backend (your Week 6 GCS bucket) ────────────────────
  # Stores terraform.tfstate in GCS instead of on disk.
  # Replace cis410-yourname-xxxx with your actual Project ID.
  backend "gcs" {
    bucket = "cis410-julia-tfstate" # ← your exact bucket name
    prefix = "terraform/week7"
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
# ── Call the networking child module ─────────────────────────────────────
# source = path to the module directory (relative to this file).
# All variables declared in modules/networking/variables.tf are set here.
module "networking" {
  source      = "./modules/networking"
  project_id  = var.project_id
  region      = var.region
  vpc_name    = "cis410-vpc"
  subnet_cidr = "10.0.1.0/24"
  my_ip_cidr  = var.my_ip_cidr
}
