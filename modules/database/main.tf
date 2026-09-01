resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids


  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Project     = var.project_name
    Environment = "dev"
    Tier        = "Private"
    ManagedBy   = "Terraform"
  }
}
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-mysql"

  engine = "mysql"

  instance_class = var.db_instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.security_group_id]

  publicly_accessible = false

  skip_final_snapshot = true

  backup_retention_period = 7

  storage_encrypted = true

  tags = {
    Name        = "${var.project_name}-mysql"
    Project     = var.project_name
    Environment = "dev"
    Tier        = "Private"
    Role        = "Database"
    ManagedBy   = "Terraform"
  }
}