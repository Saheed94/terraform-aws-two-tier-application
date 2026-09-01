module "networking" {
  source = "./modules/networking"

  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidr    = var.public_subnet_cidr
  private_subnet_cidr   = var.private_subnet_cidr
  private_subnet_cidr_2 = var.private_subnet_cidr_2
  availability_zone     = var.availability_zone
  availability_zone_2   = var.availability_zone_2
}
module "security_groups" {
  source = "./modules/security-groups"

  project_name     = var.project_name
  vpc_id           = module.networking.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
}
module "compute" {
  source = "./modules/compute"

  project_name  = var.project_name
  instance_type = var.instance_type

  subnet_id = module.networking.public_subnet_id

  security_group_id = module.security_groups.ec2_security_group_id
}
module "database" {
  source = "./modules/database"

  project_name = var.project_name

  vpc_id = module.networking.vpc_id

  private_subnet_ids = [
    module.networking.private_subnet_id,
    module.networking.private_subnet_id_2
  ]

  security_group_id = module.security_groups.rds_security_group_id

  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  allocated_storage = var.allocated_storage
}