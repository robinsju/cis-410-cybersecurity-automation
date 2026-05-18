# terraform/week7/modules/networking/main.tf
# ────────────────────────────────────────────────────────────────────────
# Child module: VPC, public subnet, and three firewall rules.
# Called by the root module (terraform/week7/main.tf).
# ────────────────────────────────────────────────────────────────────────
# ── VPC ──────────────────────────────────────────────────────────────────
# auto_create_subnetworks = false: we define subnets manually (best practice).
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}
# ── Public Subnet ────────────────────────────────────────────────────────
# network = google_compute_network.vpc.id creates an implicit dependency.
# Terraform creates the VPC before this subnet automatically.
resource "google_compute_subnetwork" "public" {
  name          = "${var.vpc_name}-public"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
}
# ── Firewall: SSH from your IP only ──────────────────────────────────────
# /32 = one exact IP address. Never use 0.0.0.0/0 on port 22.
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.vpc_name}-allow-ssh"
  network = google_compute_network.vpc.name
  project = var.project_id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = [var.my_ip_cidr]
  target_tags   = ["ssh-enabled"]
  description   = "Allow SSH from operator IP only"
}
# ── Firewall: HTTP from the internet ─────────────────────────────────────
# 0.0.0.0/0 on port 80 is intentional — web servers must be reachable.
# target_tags limits this rule to VMs tagged web-server only.
resource "google_compute_firewall" "allow_http" {
  name    = "${var.vpc_name}-allow-http"
  network = google_compute_network.vpc.name
  project = var.project_id
  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
  description   = "Allow HTTP traffic to web-tagged resources"
}
# ── Firewall: Explicit deny-all fallback ─────────────────────────────────
# priority 65000 = lowest priority (1000 is default for allow rules).
# Allow rules above take precedence. Everything else is blocked.
resource "google_compute_firewall" "deny_all_ingress" {
  name      = "${var.vpc_name}-deny-ingress"
  network   = google_compute_network.vpc.name
  project   = var.project_id
  priority  = 65000
  direction = "INGRESS"
  deny { protocol = "all" }
  source_ranges = ["0.0.0.0/0"]
  description   = "Explicit deny-all fallback — blocks unmatched traffic"
}
resource "google_compute_firewall" "allow_https" {
  name    = "${var.vpc_name}-allow-https-manual"
  network = google_compute_network.vpc.name
  project = var.project_id
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
}
