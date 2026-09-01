output "vpc_id" {
  description = "ID of the project VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = module.networking.private_subnet_id
}
output "db_instance_id" {
  description = "ID of the RDS instance"
  value       = module.database.db_instance_id
}

output "db_endpoint" {
  description = "RDS endpoint"
  value       = module.database.db_endpoint
}

output "db_port" {
  description = "RDS port"
  value       = module.database.db_port
}

output "db_name" {
  description = "Database name"
  value       = module.database.db_name
}