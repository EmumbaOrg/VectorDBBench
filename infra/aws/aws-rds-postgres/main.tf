locals {
  common_tags = {
    "Name"        = join("-", [var.name_prefix, var.pgrds_module_name_prefix, "postgres"])
    "pgrds_module_name_prefix" = var.pgrds_module_name_prefix
    "Module"      = "RDS"
    "Terraform"   = "true"
    "CreatedBy"   = "Vector-Benchmarking-IaC"
    "PartOfInfra" = "true"
  }
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.8.0"
  
  instance_use_identifier_prefix = false
  identifier           = join("-", [var.name_prefix, var.pgrds_module_name_prefix, "postgres"])
  engine               = var.pgrds_engine
  engine_version       = var.pgrds_engine_version
  family               = var.pgrds_family               # DB parameter group
  major_engine_version = var.pgrds_engine_version       # DB option group
  instance_class       = var.pgrds_instance_class

  storage_type          = var.pgrds_storage_type
  allocated_storage     = var.pgrds_allocated_storage
  max_allocated_storage = var.pgrds_pgrds_max_allocated_storage

  db_name               = var.pgrds_db_name
  username              = var.pgrds_db_user
  password              = var.pgrds_db_master_password
  port                  = var.pgrds_db_port

  availability_zone     = var.pgrds_az[0]
  multi_az              = var.pgrds_multi_az

  create_db_subnet_group          = var.pgrds_create_db_subnet_group
  db_subnet_group_name            = join("-", [var.name_prefix, var.pgrds_module_name_prefix, "postgres", "main"])
  db_subnet_group_use_name_prefix = false
  subnet_ids                      = var.public_subnet_ids
  vpc_security_group_ids          = [module.security_group.security_group_id]
  manage_master_user_password     = false
  maintenance_window              = var.pgrds_maintenance_window
  backup_window                   = var.pgrds_backup_window
  monitoring_role_name            = join("-", [var.name_prefix, var.pgrds_module_name_prefix, "postgres", "main"])
  monitoring_role_use_name_prefix = false
  enabled_cloudwatch_logs_exports = var.pgrds_enabled_cloudwatch_logs_exports

  backup_retention_period         = var.pgrds_backup_retention_period
  skip_final_snapshot             = var.pgrds_skip_final_snapshot
  deletion_protection             = var.pgrds_deletion_protection

  cloudwatch_log_group_retention_in_days = var.pgrds_cloudwatch_log_group_retention_in_days

  performance_insights_enabled          = var.pgrds_performance_insights_enabled
  performance_insights_retention_period = var.pgrds_performance_insights_retention_period
  create_monitoring_role                = var.pgrds_create_monitoring_role
  monitoring_interval                   = var.pgrds_monitoring_interval


  # Specifies whether to remove automated backups immediately after the DB instance is deleted
  delete_automated_backups              = var.pgrds_delete_automated_backups
  iam_database_authentication_enabled   = var.pgrds_iam_database_authentication_enabled

  tags = local.common_tags

  option_group_name                     = join("-", [var.name_prefix, var.pgrds_module_name_prefix, "postgres", "main"])
  option_group_use_name_prefix          = false
  option_group_description              = join("-", [var.name_prefix, var.pgrds_module_name_prefix, "postgres", "main"])

  parameter_group_name                  = join("-", [var.name_prefix, var.pgrds_module_name_prefix, "postgres", "main"])
  parameter_group_use_name_prefix       = false
  parameter_group_description           = join("-", [var.name_prefix, var.pgrds_module_name_prefix, "postgres", "main"])
  parameters = [
    {
      name  = "password_encryption"
      value = "md5"
    }
  ]

  db_option_group_tags = {
    "Sensitive" = "low"
  }

  db_parameter_group_tags = {
    "Sensitive" = "low"
  }

}

# Security group for RDS
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name                         = join("-", [var.name_prefix, var.pgrds_module_name_prefix, "postgres", "sg", "main"])
  description                  = join("-", [var.name_prefix, var.pgrds_module_name_prefix, "postgres", "sg", "main"])
  vpc_id                       = var.pg_vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL access from public IP"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      rule                     = "postgresql-tcp"
      cidr_blocks              = "0.0.0.0/0"
    },
  ]
  tags = local.common_tags
}