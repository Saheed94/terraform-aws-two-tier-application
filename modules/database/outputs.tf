output "db_instance_id" {
  description = "ID of the RDS database instance"
  value       = aws_db_instance.main.id
}

output "db_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "RDS database port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}