# terraform/week7/variables.tf
variable "project_id" {
  description = "Your GCP project ID (e.g. cis410-yourname-xxxx)"
  type        = string
}
variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}
variable "my_ip_cidr" {
  description = "Your public IP for SSH access (format: x.x.x.x/32)"
  type        = string
}
