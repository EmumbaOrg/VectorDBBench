
##################################################################################
# MODULES
##################################################################################

module "pg_vpc" {
  source      = "./aws-vpc"
  name_prefix = var.name_prefix
  vpc_module_name_prefix = var.vpc_module_name_prefix
  vpc_cidr = var.vpc_cidr
  vpcregion = var.aws_region
  vpc_azs = var.az
  vpc_number_of_priv_cidr = var.number_of_priv_cidr
  vpc_number_of_pub_cidr = var.number_of_pub_cidr
  vpc_public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  vpc_private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  vpc_enable_dns_hostnames = var.enable_dns_hostnames
  vpc_create_igw = var.create_igw
  vpc_enable_dns_support = var.enable_dns_support
  vpc_enable_nat_gateway = var.enable_nat_gateway
  vpc_single_nat_gateway = var.single_nat_gateway
}

module "pg_rds" {
  depends_on = [ module.pg_vpc ]
  source      = "./aws-rds-postgres"
  name_prefix  = var.name_prefix
  pgrds_module_name_prefix = var.rds_module_name_prefix
  pgrds_engine = var.rds_engine 
  pgrds_db_name = var.rds_db_name
  pgrds_db_user = var.rds_db_user
  pgrds_db_port = var.rds_db_port
  pgrds_instance_class = var.rds_instance_class
  pgrds_engine_version = var.rds_engine_version
  pgrds_major_engine_version = var.rds_major_engine_version
  pgrds_family = var.rds_family
  pgrds_allocated_storage = var.rds_allocated_storage
  pgrds_db_master_password = var.rds_db_master_password
  pgrds_pgrds_max_allocated_storage = var.rds_max_allocated_storage
  pgrds_storage_type = var.rds_storage_type
  pg_vpc_id = module.pg_vpc.vpc_id
  private_subnet_ids = [module.pg_vpc.private_subnets[0], module.pg_vpc.private_subnets[1]]
  public_subnet_ids = [module.pg_vpc.public_subnets[0], module.pg_vpc.public_subnets[1]]
  pgrds_maintenance_window = var.rds_maintenance_window
  pgrds_backup_retention_period = var.rds_backup_retention_period
  pgrds_backup_window = var.rds_backup_window
  pgrds_cloudwatch_log_group_retention_in_days = var.rds_cloudwatch_log_group_retention_in_days
  pgrds_create_db_subnet_group = var.rds_create_db_subnet_group
  pgrds_create_monitoring_role = var.rds_create_monitoring_role
  pgrds_delete_automated_backups = var.rds_delete_automated_backups
  pgrds_deletion_protection = var.rds_deletion_protection
  pgrds_enabled_cloudwatch_logs_exports = var.rds_enabled_cloudwatch_logs_exports
  pgrds_iam_database_authentication_enabled = var.rds_iam_database_authentication_enabled
  pgrds_monitoring_interval = var.rds_monitoring_interval
  pgrds_multi_az = var.rds_multi_az
  pgrds_performance_insights_enabled = var.rds_performance_insights_enabled
  pgrds_performance_insights_retention_period = var.rds_performance_insights_retention_period
  pgrds_skip_final_snapshot = var.rds_skip_final_snapshot
  pgrds_az = var.rds_az
}

module "bench_ec2" {
   depends_on = [ module.pg_vpc ]
   source      = "./aws-bench-ec2"
   name_prefix = var.name_prefix
   module_name_prefix      = var.bench_module_name_prefix
   region = var.aws_region
   vpc_id = module.pg_vpc.vpc_id
   pub_subnet_id = module.pg_vpc.public_subnets[0]
   az = [module.pg_vpc.azs[0]]
   benchec2_monitoring = var.ec2_monitoring
   benchec2_ami = var.ec2_ami
   benchec2_instance_type = var.ec2_instance_type
   benchec2_associate_public_ip_address = var.ec2_associate_public_ip_address
   benchec2_eip_domain = var.ec2_eip_domain
   benchec2_username = var.ec2_username
}

module "db_ec2" {
   depends_on = [ module.pg_vpc ]
   source      = "./aws-db-ec2"
   name_prefix = var.name_prefix
   module_name_prefix      = var.db_module_name_prefix
   region = var.aws_region
   vpc_id = module.pg_vpc.vpc_id
   pub_subnet_id = module.pg_vpc.public_subnets[0]
   az = [module.pg_vpc.azs[0]]
   sg_ingress = ["allow ssh from emumba", "*", "22", "TCP"]
   dbec2_monitoring = var.dbec2_monitoring
   dbec2_ami = var.dbec2_ami
   dbec2_instance_type = var.dbec2_instance_type
   dbec2_associate_public_ip_address = var.dbec2_associate_public_ip_address
   dbec2_eip_domain = var.dbec2_eip_domain
   dbec2_username = var.dbec2_username
 }
