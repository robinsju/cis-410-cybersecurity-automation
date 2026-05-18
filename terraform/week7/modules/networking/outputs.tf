# terraform/week7/modules/networking/outputs.tf
output "vpc_name" {
  description = "The name of the created VPC"
  value       = google_compute_network.vpc.name
}
output "vpc_id" {
  description = "The self-link of the VPC (used by Cloud Run in Week 8)"
  value       = google_compute_network.vpc.self_link
}
output "subnet_name" {
  description = "The name of the public subnet"
  value       = google_compute_subnetwork.public.name
}
output "subnet_cidr" {
  description = "The CIDR range of the subnet"
  value       = google_compute_subnetwork.public.ip_cidr_range
}
