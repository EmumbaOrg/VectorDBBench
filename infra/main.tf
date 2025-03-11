##################################################################################
#                              BLOB BACKEND
##################################################################################

#comment this block if remote backend is not required
terraform {
  backend "azurerm" {
    resource_group_name  = "PostGreSQL-Group"
    storage_account_name = "emumbaremotestate"
    container_name       = "remotetfstate"
    key                  = "terraform.tfstate"
  }
}

##################################################################################


##################################################################################
#                               AWS MODULE
##################################################################################

module "aws" {
  source = "./aws"
  count  = var.deploy_aws ? 1 : 0

  #aws region and zone
  name_prefix = var.aws_name_prefix
  aws_region  = var.aws_region
  az          = var.aws_az

  #vpc configuration
  vpc_module_name_prefix     = var.aws_vpc_module_name_prefix
  vpc_cidr                   = var.aws_vpc_cidr
  create_igw                 = var.aws_create_igw
  enable_nat_gateway         = var.aws_enable_nat_gateway
  single_nat_gateway         = var.aws_single_nat_gateway
  number_of_priv_cidr        = var.aws_number_of_priv_cidr
  number_of_pub_cidr         = var.aws_number_of_pub_cidr
  public_subnet_cidr_blocks  = var.aws_public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.aws_private_subnet_cidr_blocks
  enable_dns_hostnames       = var.aws_enable_dns_hostnames
  enable_dns_support         = var.aws_enable_dns_support

  #bench ec2 configuration
  bench_module_name_prefix        = var.aws_bench_module_name_prefix
  ec2_monitoring                  = var.aws_ec2_monitoring
  ec2_ami                         = var.aws_ec2_ami
  ec2_instance_type               = var.aws_ec2_instance_type
  ec2_associate_public_ip_address = var.aws_ec2_associate_public_ip_address
  ec2_eip_domain                  = var.aws_ec2_eip_domain
  ec2_username                    = var.aws_ec2_username

  #dbec2 configuration
  db_module_name_prefix             = var.aws_db_module_name_prefix
  dbec2_monitoring                  = var.aws_dbec2_monitoring
  dbec2_ami                         = var.aws_dbec2_ami
  dbec2_instance_type               = var.aws_dbec2_instance_type
  dbec2_associate_public_ip_address = var.aws_dbec2_associate_public_ip_address
  dbec2_eip_domain                  = var.aws_dbec2_eip_domain
  dbec2_username                    = var.aws_dbec2_username

  #rds configuration
  rds_module_name_prefix                     = var.aws_rds_module_name_prefix
  rds_engine                                 = var.aws_rds_engine
  rds_engine_version                         = var.aws_rds_engine_version
  rds_family                                 = var.aws_rds_family
  rds_major_engine_version                   = var.aws_rds_major_engine_version
  rds_instance_class                         = var.aws_rds_instance_class
  rds_storage_type                           = var.aws_rds_storage_type
  rds_allocated_storage                      = var.aws_rds_allocated_storage
  rds_max_allocated_storage                  = var.aws_rds_max_allocated_storage
  rds_db_name                                = var.aws_rds_db_name
  rds_db_user                                = var.aws_rds_db_user
  rds_db_master_password                     = var.aws_rds_db_master_password
  rds_db_port                                = var.aws_rds_db_port
  rds_az                                     = var.aws_rds_az
  rds_multi_az                               = var.aws_rds_multi_az
  rds_create_db_subnet_group                 = var.aws_rds_create_db_subnet_group
  rds_maintenance_window                     = var.aws_rds_maintenance_window
  rds_backup_window                          = var.aws_rds_backup_window
  rds_enabled_cloudwatch_logs_exports        = ["postgresql"] #var.aws_rds_enabled_cloudwatch_logs_exports
  rds_backup_retention_period                = var.aws_rds_backup_retention_period
  rds_skip_final_snapshot                    = var.aws_rds_skip_final_snapshot
  rds_deletion_protection                    = var.aws_rds_deletion_protection
  rds_performance_insights_enabled           = var.aws_rds_performance_insights_enabled
  rds_cloudwatch_log_group_retention_in_days = var.aws_rds_cloudwatch_log_group_retention_in_days
  rds_performance_insights_retention_period  = var.aws_rds_performance_insights_retention_period
  rds_create_monitoring_role                 = var.aws_rds_create_monitoring_role
  rds_delete_automated_backups               = var.aws_rds_delete_automated_backups
  rds_iam_database_authentication_enabled    = var.aws_rds_iam_database_authentication_enabled
  rds_monitoring_interval                    = var.aws_rds_monitoring_interval
  private_subnet_ids                         = var.aws_private_subnet_ids
}
##################################################################################
#                               AZURE MODULE
##################################################################################

module "azure" {
  source = "./azure"
  count  = var.deploy_azure ? 1 : 0

  #azure region and configuration
  name_prefix        = var.azure_name_prefix
  location           = var.azure_location
  zone               = var.azure_zone
  resourcegroup_name = var.azure_resourcegroup_name

  #azure vnet
  vnet_module_name_prefix = var.azure_vnet_module_name_prefix
  vnet_ipaddress          = var.azure_vnet_ipaddress
  vnet_subnet_address     = var.azure_vnet_subnet_address

  #azure flex db
  flex_module_name_prefix = var.azure_flex_module_name_prefix
  flex_server_storage     = var.azure_flex_server_storage
  flex_server_sku         = var.azure_flex_server_sku
  flex_dbuser             = var.azure_flex_dbuser
  flex_dbpassword         = var.azure_flex_dbpassword
  flex_publicaccess       = var.azure_flex_publicaccess
  flex_pgversion          = var.azure_flex_pgversion

  #azure bench vm
  benchvm_module_name_prefix   = var.azure_benchvm_module_name_prefix
  ip_sku                       = var.azure_ip_sku
  public_ip_allocation_method  = var.azure_public_ip_allocation_method
  private_ip_allocation_method = var.azure_private_ip_allocation_method
  vm_type                      = var.azure_vm_type
  vm_username                  = var.azure_vm_username
  vm_os_caching                = var.azure_vm_os_caching
  vm_disk_storage_account_type = var.azure_vm_disk_storage_account_type
  vm_disk_size                 = var.azure_vm_disk_size
  vm_image_publisher           = var.azure_vm_image_publisher
  vm_image_offer               = var.azure_vm_image_offer
  vm_image_sku                 = var.azure_vm_image_sku
  vm_image_version             = var.azure_vm_image_version

  #azure db vm
  dbvm_module_name_prefix           = var.azure_dbvm_module_name_prefix
  dbvm_ip_sku                       = var.azure_dbvm_ip_sku
  dbvm_public_ip_allocation_method  = var.azure_dbvm_public_ip_allocation_method
  dbvm_private_ip_allocation_method = var.azure_dbvm_private_ip_allocation_method
  dbvm_vm_type                      = var.azure_dbvm_vm_type
  dbvm_vm_username                  = var.azure_dbvm_vm_username
  dbvm_vm_os_caching                = var.azure_dbvm_vm_os_caching
  dbvm_vm_disk_storage_account_type = var.azure_dbvm_vm_disk_storage_account_type
  dbvm_vm_disk_size                 = var.azure_dbvm_vm_disk_size
  dbvm_vm_image_publisher           = var.azure_dbvm_vm_image_publisher
  dbvm_vm_image_offer               = var.azure_dbvm_vm_image_offer
  dbvm_vm_image_sku                 = var.azure_dbvm_vm_image_sku
  dbvm_vm_image_version             = var.azure_dbvm_vm_image_version


}

##################################################################################
#                               GCP MODULE
##################################################################################
module "gcp" {
  source = "./gcp"
  count  = var.deploy_gcp ? 1 : 0

  #gcp cnet
  name_prefix                     = var.gcp_name_prefix
  cnet_module_name_prefix         = var.gcp_cnet_module_name_prefix
  cidr_range                      = var.gcp_cnet_cidr_range
  auto_subnet_create              = var.gcp_cnet_auto_subnet_create
  routing_mode                    = var.gcp_cnet_routing_mode
  cnet_region                     = var.gcp_cnet_region
  cnet_zone                       = var.gcp_cnet_zone
  compute_address_provider        = var.gcp_cnet_compute_address_provider
  compute_address_purpose         = var.gcp_cnet_compute_address_purpose
  compute_address_type            = var.gcp_cnet_compute_address_type
  compute_address_prefix_length   = var.gcp_cnet_compute_address_prefix_length
  compute_firewall_allow_protocol = var.gcp_cnet_compute_firewall_allow_protocol
  compute_firewall_allow_ports    = var.gcp_cnet_compute_firewall_allow_ports
  compute_firewall_source_ranges  = var.gcp_cnet_compute_firewall_source_ranges

  #gcp cloudsql
  csql_module_name_prefix              = var.gcp_csql_module_name_prefix
  csql_random_instance_name            = var.gcp_csql_random_instance_name
  csql_project_id                      = var.gcp_csql_project_id
  csql_databse_version                 = var.gcp_csql_databse_version
  csql_region                          = var.gcp_csql_region
  csql_zone                            = var.gcp_csql_zone
  csql_tier                            = var.gcp_csql_tier
  csql_availability_type               = var.gcp_csql_availability_type
  csql_maintenance_window_day          = var.gcp_csql_maintenance_window_day
  csql_maintenance_window_hour         = var.gcp_csql_maintenance_window_hour
  csql_maintenance_window_update_track = var.gcp_csql_maintenance_window_update_track
  csql_deletion_protection             = var.gcp_csql_deletion_protection
  csql_ipv4_configuration              = var.gcp_csql_ipv4_configuration
  csql_ssl_mode                        = var.gcp_csql_ssl_mode
  csql_private_network                 = var.gcp_csql_private_network
  csql_allocated_ip_range              = var.gcp_csql_allocated_ip_range
  csql_authorized_networks             = var.gcp_csql_authorized_networks
  csql_backup_configuration            = var.gcp_csql_backup_configuration
  csql_start_time                      = var.gcp_csql_start_time
  csql_backup_location                 = var.gcp_csql_backup_location
  csql_point_in_time_recovery_enabled  = var.gcp_csql_point_in_time_recovery_enabled
  csql_transaction_log_retention_days  = var.gcp_csql_transaction_log_retention_days
  csql_retained_backups                = var.gcp_csql_retained_backups
  csql_retention_unit                  = var.gcp_csql_retention_unit
  csql_db_charset                      = var.gcp_csql_db_charset
  csql_db_collation                    = var.gcp_csql_db_collation
  csql_user_name                       = var.gcp_csql_user_name
  csql_user_password                   = var.gcp_csql_user_password

  #gcp bench ce
  benchce_module_name_prefix = var.gcp_module_name_prefix
  image                      = var.gcp_benchce_image
  size                       = var.gcp_benchce_size
  type                       = var.gcp_benchce_machine_type
  benchce_zone               = var.gcp_cnet_zone
  benchce_region             = var.gcp_cnet_region
  module_name_prefix         = var.gcp_module_name_prefix

  #gcp db ce
  #dbce_module_name_prefix = var.gcp_module_name_prefix
  dbce_image              = var.gcp_dbce_image
  dbce_size               = var.gcp_dbce_size
  dbce_type               = var.gcp_dbce_machine_type
  dbce_zone               = var.gcp_dbce_zone
  dbce_region             = var.gcp_dbce_region
  dbce_module_name_prefix = var.gcp_dbce_module_name_prefix
}
