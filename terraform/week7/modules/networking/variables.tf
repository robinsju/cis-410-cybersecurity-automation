# terraform/week7/modules/networking/variables.tf
variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "region" {
  description = "GCP region for the subnet"
  type        = string
  default     = "us-central1"
}
variable "vpc_name" {
  description = "Name prefix for the VPC and all resources"
  type        = string
}
variable "subnet_cidr" {
  description = "CIDR block for the public subnet (e.g. 10.0.1.0/24)"
  type        = string
}
variable "my_ip_cidr" {
  description = "Your public IP for SSH access (e.g. 203.0.113.5/32)"
  type        = string
}
