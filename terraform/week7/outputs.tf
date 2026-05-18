# terraform/week7/outputs.tf
output "vpc_name" {
  value = module.networking.vpc_name
}
output "vpc_id" {
  value = module.networking.vpc_id
}
output "subnet_name" {
  value = module.networking.subnet_name
}
