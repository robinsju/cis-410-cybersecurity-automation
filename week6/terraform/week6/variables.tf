variable "project_id" {
  description = "Your GCP Project ID (e.g. cis410-julia)"
  type        = string
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "us-west1"
}
