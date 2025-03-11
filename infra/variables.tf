#==================================================================
#========================= CSP FLAG VARIABLES =====================
#==================================================================
variable "deploy_aws" {
  description = "Whether to deploy the AWS module"
  type        = bool
}

variable "deploy_azure" {
  description = "Whether to deploy the Azure module"
  type        = bool
}

variable "deploy_gcp" {
  description = "Whether to deploy the GCP module"
  type        = bool
}

#=================================================================
#======================= AWS VARIABLES ===========================
#=================================================================

variable "aws_region" {
  type        = string
  description = "AWS region for deployment"

}

variable "aws_az" {
  type        = list(string)
  description = "Availability zones"
}

variable "aws_name_prefix" {
  description = "Name Prefix"
}

#============================ VPC ========================================
variable "aws_vpc_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "aws_vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "aws_create_igw" {
  type        = bool
  description = "A boolean flag to create internet gateway in the VPC. Defaults true."
}

variable "aws_enable_nat_gateway" {
  type        = bool
  description = "A boolean flag to create NAT gateway for private subnets. Defaults true."
}

variable "aws_single_nat_gateway" {
  type        = bool
  description = "Enable only one NAT gateway. Defaults true."
}

variable "aws_number_of_priv_cidr" {
  type        = string
  description = "Define Number of private subnets"
}

variable "aws_number_of_pub_cidr" {
  type        = string
  description = "Define Number of public subnets"
}

variable "aws_public_subnet_cidr_blocks" {
  type        = list(string)
  description = "Public subnets CIDR blocks"
}

variable "aws_private_subnet_cidr_blocks" {
  type        = list(string)
  description = "Private subnets CIDR blocks"
}

variable "aws_enable_dns_hostnames" {
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
}

variable "aws_enable_dns_support" {
  type        = bool
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
}

#=============================== BENCH EC2 CONFIG ===========================================

variable "aws_bench_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "aws_ec2_monitoring" {
  type = bool
  description = "Enable/disable detailed monitoring for ec2"
}

variable "aws_ec2_ami" {
  type        = string
  description = "AMI to use for the instance."
}

variable "aws_ec2_instance_type" {
  type        = string
  description = "The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance."
}

variable "aws_ec2_associate_public_ip_address" {
  type        = bool
  description = "Whether to associate a public IP address with an instance in a VPC."
}

variable "aws_ec2_eip_domain" {
  type        = string
  description = "Indicates if this EIP is for use in VPC."
}

variable "aws_ec2_username" {
  type        = string
  description = "Bench Ec2 username"
}

#=============================== DB EC2 CONFIG ===============================================

variable "aws_db_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "aws_dbec2_monitoring" {
  type = bool
  description = "Enable/disable detailed monitoring for ec2"
}

variable "aws_dbec2_ami" {
  type        = string
  description = "AMI to use for the instance."
}

variable "aws_dbec2_instance_type" {
  type        = string
  description = "The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance."
}

variable "aws_dbec2_associate_public_ip_address" {
  type        = bool
  description = "Whether to associate a public IP address with an instance in a VPC."
}

variable "aws_dbec2_eip_domain" {
  type        = string
  description = "Indicates if this EIP is for use in VPC."
}

variable "aws_dbec2_username" {
  type        = string
  description = "db Ec2 username"
}

#=============================== RDS CONFIG =================================================

variable "aws_rds_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "aws_rds_engine" {
  type = string
  description = "RDS engine to be launched."
}

variable "aws_rds_engine_version" {
  type = string
  description = "RDS engine version to be launched."
}

variable "aws_rds_family" {
  type = string
  description = "RDS family in parameter group"
}

variable "aws_rds_major_engine_version" {
  type = string
  description = "RDS major engine version to be set in option group"
}

variable "aws_rds_instance_class" {
  type = string
  description = "Instance for the RDS to be launched."
}

variable "aws_rds_storage_type" {
  type = string
  description = "Storage type"
}

variable "aws_rds_allocated_storage" {
  type = number
  description = "Storage to be allocated to RDS in GB"
}

variable "aws_rds_max_allocated_storage" {
  type = number
  description = "Maximum storage to be allowed to RDS."
}

variable "aws_rds_db_name" {
  type        = string
  description = "Database name"
}

variable "aws_rds_db_user" {
  type        = string
  description = "Database user"
}

variable "aws_rds_db_master_password" {
  type        = string
  description = "Database master password"
}

variable "aws_rds_db_port" {
  type = number
  description = "Port to be used for RDS"
}

variable "aws_rds_az" {
  type        = list(string)
  description = "Availability zones"
}

variable "aws_rds_multi_az" {
  type = bool
  description = "Whether the RDS deployment should be multi-az or single-az."
}

variable "aws_rds_create_db_subnet_group" {
  type = bool
  description = "Whether to create a database subnet group"
}

variable "aws_rds_maintenance_window" {
  type = string
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
}

variable "aws_rds_backup_window" {
  type = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
}

variable "aws_rds_enabled_cloudwatch_logs_export" {
  type        = list(string)
  default     = ["postgresql", "upgrade"]
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): alert, audit, error, general, listener, slowquery, trace, postgresql (PostgreSQL), upgrade (PostgreSQL)"
}

variable "aws_rds_backup_retention_period" {
  type = number
  description = "Numbers of days backup should be retained."
}

variable "aws_rds_skip_final_snapshot" {
  type = bool
  description = "When deleting the DB whether to create a final snapshot"
}

variable "aws_rds_deletion_protection" {
  type = bool
  description = "Deletion protection for DB. Have to disable deletion protection before deleting the DB."
}

variable "aws_rds_performance_insights_enabled" {
  type = bool
  description = "Amazon RDS Performance Insights is a database performance tuning and monitoring feature that helps you quickly assess the load on your database."
}

variable "aws_rds_cloudwatch_log_group_retention_in_days" {
  type = number
  description = "The number of days to retain CloudWatch logs for the DB instance"
}

variable "aws_rds_performance_insights_retention_period" {
  type = number
  description = "The amount of time to retain Performance Insights data. The retention setting in the free tier is Default (7 days). To retain your performance data for longer, specify 1/24 months."
}

variable "aws_rds_create_monitoring_role" {
  type = bool
  description = "Ceate IAM role with a defined name that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
}

variable "aws_rds_monitoring_interval" {
  type = number
  description = " The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60"
}

variable "aws_rds_delete_automated_backups" {
  type = bool
  description = "Whether to delete the automated backups or not"
}

variable "aws_rds_iam_database_authentication_enabled" {
  type = bool
  description = "Is IAM db authentication required or not"
}

variable "aws_private_subnet_ids" {
  type = list(string)
  description = "Private subnet IDs"
}

#=================================================================
#======================= AZURE VARIABLES ===========================
#=================================================================

variable "azure_name_prefix" {
  type        = string
  description = "Name Prefix"
}

variable "azure_location" {
  type        = string
  description = "Location of the resource."
}

variable "azure_zone" {
  type        = string
  description = "Zone of the resource."
}

variable "azure_resourcegroup_name" {
  type        = string
  description = "Name of the resource group."
}

####################### VNET VARIABLES ##############################

variable "azure_vnet_module_name_prefix" {
  type        = string
  description = "Module Prefix name."
}

variable "azure_vnet_ipaddress" {
  description = "Address space of the vnet."
}

variable "azure_vnet_subnet_address" {
  default     = ["10.0.0.0/24"]
  description = "subnets of the vnet."
}


####################### FLEXIBLE DB VARIABLES #######################

variable "azure_flex_module_name_prefix" {
  type        = string
  description = "Name of the flexible DB server module."
}

variable "azure_flex_server_storage" {
  type        = number
  description = "Size of DB server storage in MBs"
}

variable "azure_flex_server_sku" {
  type        = string
  description = "Sku of flexible DB server"
}

variable "azure_flex_dbuser" {
  type        = string
  description = "username for flexible Database"
}

variable "azure_flex_dbpassword" {
  type        = string
  description = "Password of flexible Database."
}

variable "azure_flex_publicaccess" {
  type        = bool
  description = "Public access of database."
}

variable "azure_flex_pgversion" {
  type        = string
  description = "PostGres version."
}

######################### BENCH VM VARIABLES ##########################
variable "azure_benchvm_module_name_prefix" {
  type        = string
  description = "Name of the module."
}

variable "azure_ip_sku" {
  type        = string
  description = "Sku for public ip."
}

variable "azure_public_ip_allocation_method" {
  type        = string
  description = "Allocation method for public ip."
}

variable "azure_private_ip_allocation_method" {
  type        = string
  description = "Allocation method for private ip."
}

variable "azure_vm_type" {
  type        = string
  description = "Vm class/type as per official documentation."
}

variable "azure_vm_username" {
  type        = string
  description = "username for vm machine access."
}

variable "azure_vm_os_caching" {
  type        = string
  description = "OS caching mode ."
}

variable "azure_vm_disk_storage_account_type" {
  type        = string
  description = "Disk Storage type for VM."
}

variable "azure_vm_disk_size" {
  type        = string
  description = "VM disk size in GB."
}

variable "azure_vm_image_publisher" {
  type        = string
  description = "VM image publisher type."
}

variable "azure_vm_image_offer" {
  type        = string
  description = "VM image offer."
}

variable "azure_vm_image_sku" {
  type        = string
  description = "VM image sku."
}

variable "azure_vm_image_version" {
  type        = string
  description = "VM image version."
}

############# ########### DB VM VARIABLES #############################

variable "azure_dbvm_module_name_prefix" {
  type = string
  description = "Name of the module."
}

variable "azure_dbvm_ip_sku" {
  type = string
  description = "Sku for public ip."
}

variable "azure_dbvm_public_ip_allocation_method" {
  description = "Allocation method for public ip."
  type        = string
}

variable "azure_dbvm_private_ip_allocation_method" {
  description = "Allocation method for private ip."
  type        = string
}

variable "azure_dbvm_vm_type" {
  description = "Vm class/type as per official documentation."
  type        = string
}

variable "azure_dbvm_vm_username" {
  description = "username for vm machine access."
  type        = string
}

variable "azure_dbvm_vm_os_caching" {
  description = "OS caching mode ."
  type        = string
}

variable "azure_dbvm_vm_disk_storage_account_type" {
  description = "Disk Storage type for VM."
  type        = string
}

variable "azure_dbvm_vm_disk_size" {
  description = "VM disk size in GB."
  type        = string
}

variable "azure_dbvm_vm_image_publisher" {
  description = "VM image publisher type."
  type        = string
}

variable "azure_dbvm_vm_image_offer" {
  description = "VM image offer."
  type        = string
}

variable "azure_dbvm_vm_image_sku" {
  description = "VM image sku."
  type        = string
}

variable "azure_dbvm_vm_image_version" {
  description = "VM image version."
  type        = string
}

#=================================================================
#======================= GCP VARIABLES ===========================
#=================================================================

variable "gcp_name_prefix" {
  type        = string
  description = "Name Prefix"
}

variable "gcp_benchce_region" {
  type        = string
  description = "region of compute engine"
}

variable "gcp_benchce_zone" {
  type        = string
  description = "zone of compute engine"
}

#====================== BENCH COMPUTE ENGINE ============================
variable "gcp_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "gcp_benchce_image" {
  type        = string
  description = "compute engine image"
}

variable "gcp_benchce_size" {
  type        = string
  description = "size of compute engine"
}

variable "gcp_benchce_machine_type" {
  type        = string
  description = "instance category of compute engine"
}

#========================= GCP CNET =====================================
variable "gcp_cnet_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "gcp_cnet_cidr_range" {
  type        = string
  description = "IP CIDR RANGE OF CNET"
}

variable "gcp_cnet_auto_subnet_create" {
  type        = bool
  description = "Auto create subnets for CNET"
}

variable "gcp_cnet_routing_mode" {
  type        = string
  description = "Routing mode for CNET"
}

variable "gcp_cnet_region" {
  type        = string
  description = "Module Name Prefix"
}

variable "gcp_cnet_zone" {
  type        = string
  description = "Module Name Prefix"
}

variable "gcp_cnet_compute_address_provider" {
  type        = string
  description = "Provider for google compute address"
}

variable "gcp_cnet_compute_address_purpose" {
  type        = string
  description = "Purpose of compute address"
}

variable "gcp_cnet_compute_address_type" {
  type        = string
  description = "Address type of compute address"
}

variable "gcp_cnet_compute_address_prefix_length" {
  type        = number
  description = "Prefix length of compute address"
}

variable "gcp_cnet_compute_firewall_allow_protocol" {
  type        = list(string)
  description = "Network of compute address"
}

variable "gcp_cnet_compute_firewall_allow_ports" {
  type        = list(string)
  description = "Network of compute address"
}

variable "gcp_cnet_compute_firewall_source_ranges" {
  type        = list(string)
  description = "Network of compute address"
}

#===============================CLOUD SQL CONFIG ==============================
variable "gcp_csql_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "gcp_csql_random_instance_name" {
  type        = bool
  description = "Random instance name of postgres instance"
}

variable "gcp_csql_project_id" {
  type        = string
  description = "Project ID of GCP project"
}

variable "gcp_csql_databse_version" {
  type        = string
  description = "POstgres version"
}

variable "gcp_csql_region" {
  type        = string
  description = "GCP region"
}

variable "gcp_csql_zone" {
  type        = string
  description = "GCP zone"
}

variable "gcp_csql_tier" {
  type        = string
  description = "DB instance type"
}

variable "gcp_csql_availability_type" {
  type        = string
  description = "DB instance availability type"
}

variable "gcp_csql_maintenance_window_day" {
  type        = number
  description = "DB instance maintenance window day"
}

variable "gcp_csql_maintenance_window_hour" {
  type        = number
  description = "DB instance maintenance window hour"
}

variable "gcp_csql_maintenance_window_update_track" {
  type        = string
  description = "DB instance maintenance window update track"
}

variable "gcp_csql_deletion_protection" {
  type        = bool
  description = "DB instance deletion protection"
}

variable "gcp_csql_ipv4_configuration" {
  type        = bool
  description = "DB instance ipv4 configuration"
}

variable "gcp_csql_ssl_mode" {
  type        = string
  description = "DB instance ssl mode"
}

variable "gcp_csql_private_network" {
  type        = string
  description = "DB instance private network"
}

variable "gcp_csql_allocated_ip_range" {
  type        = string
  description = "DB instance allocated ip range"
}

variable "gcp_csql_authorized_networks" {
  type        = string
  description = "DB instance authorized networks"
}

variable "gcp_csql_backup_configuration" {
  type        = bool
  description = "DB instance backup configuration"
}

variable "gcp_csql_start_time" {
  type        = string
  description = "DB instance start time"
}

variable "gcp_csql_backup_location" {
  type        = string
  description = "DB instance location"
}

variable "gcp_csql_point_in_time_recovery_enabled" {
  type        = bool
  description = "DB instance point in time recovery enabled"
}

variable "gcp_csql_transaction_log_retention_days" {
  description = "DB instance transaction log retention days"
}

variable "gcp_csql_retained_backups" {
  type        = number
  description = "DB instance retained backups"
}

variable "gcp_csql_retention_unit" {
  type        = string
  description = "DB instance retention unit"
}

variable "gcp_csql_db_charset" {
  type        = string
  description = "DB instance charset"
}

variable "gcp_csql_db_collation" {
  type        = string
  description = "DB instance collation"
}

variable "gcp_csql_user_name" {
  type        = string
  description = "DB instance user name"
}

variable "gcp_csql_user_password" {
  type        = string
  description = "DB instance user password"
}

#=============================== DB CE CONFIG =================================
variable "gcp_dbce_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "gcp_dbce_image" {
  type        = string
  description = "compute engine image"
}

variable "gcp_dbce_size" {
  type        = string
  description = "size of compute engine"
}

variable "gcp_dbce_machine_type" {
  type        = string
  description = "instance category of compute engine"
}

variable "gcp_dbce_zone" {
  type        = string
  description = "zone of compute engine"
}

variable "gcp_dbce_region" {
  type        = string
  description = "region of compute engine"
}