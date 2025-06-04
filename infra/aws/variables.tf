
variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
}

variable "az" {
  type        = list(string)
  description = "Availability zones"
}

variable "name_prefix" {
  description = "Name Prefix"
}

#============================ VPC ========================================
variable "vpc_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "create_igw" {
  type        = bool
  description = "A boolean flag to create internet gateway in the VPC. Defaults true."
}

variable "enable_nat_gateway" {
  type        = bool
  description = "A boolean flag to create NAT gateway for private subnets. Defaults true."
}

variable "single_nat_gateway" {
  type        = bool
  description = "Enable only one NAT gateway. Defaults true."
}

variable "number_of_priv_cidr" {
  type        = string
  description = "Define Number of private subnets"
}

variable "number_of_pub_cidr" {
  type        = string
  description = "Define Number of public subnets"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "Public subnets CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "Private subnets CIDR blocks"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
}

variable "enable_dns_support" {
  type        = bool
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
}

#=============================== BENCH EC2 CONFIG ===========================================

variable "bench_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "ec2_monitoring" {
  type        = bool
  description = "Enable/disable detailed monitoring for ec2"
}

variable "ec2_ami" {
  type        = string
  description = "AMI to use for the instance."
}

variable "ec2_instance_type" {
  type        = string
  description = "The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance."
}

variable "ec2_associate_public_ip_address" {
  type        = bool
  description = "Whether to associate a public IP address with an instance in a VPC."
}

variable "ec2_eip_domain" {
  type        = string
  description = "Indicates if this EIP is for use in VPC."
}

variable "ec2_username" {
  type        = string
  description = "Bench Ec2 username"
}

#=============================== DB EC2 CONFIG ===============================================

variable "db_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "dbec2_monitoring" {
  type        = bool
  description = "Enable/disable detailed monitoring for ec2"
}

variable "dbec2_ami" {
  type        = string
  description = "AMI to use for the instance."
}

variable "dbec2_instance_type" {
  type        = string
  description = "The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance."
}

variable "dbec2_associate_public_ip_address" {
  type        = bool
  description = "Whether to associate a public IP address with an instance in a VPC."
}

variable "dbec2_eip_domain" {
  type        = string
  description = "Indicates if this EIP is for use in VPC."
}

variable "dbec2_username" {
  type        = string
  description = "db Ec2 username"
}

#=============================== RDS CONFIG =================================================

variable "rds_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "rds_engine" {
  type        = string
  description = "RDS engine to be launched."
}

variable "rds_engine_version" {
  type        = string
  description = "RDS engine version to be launched."
}

variable "rds_family" {
  type        = string
  description = "RDS family in parameter group"
}

variable "rds_major_engine_version" {
  type        = string
  description = "RDS major engine version to be set in option group"
}

variable "rds_instance_class" {
  type        = string
  description = "Instance for the RDS to be launched."
}

variable "rds_storage_type" {
  type        = string
  description = "Storage type"
}

variable "rds_allocated_storage" {
  type        = number
  description = "Storage to be allocated to RDS in GB"
}

variable "rds_max_allocated_storage" {
  type        = number
  description = "Maximum storage to be allowed to RDS."
}

variable "rds_db_name" {
  type        = string
  description = "Database name"
}

variable "rds_db_user" {
  type        = string
  description = "Database user"
}

variable "rds_db_master_password" {
  type        = string
  description = "Database master password"
}

variable "rds_db_port" {
  type        = number
  description = "Port to be used for RDS"
}

variable "rds_az" {
  type        = list(string)
  description = "Availability zones"
}

variable "rds_multi_az" {
  type        = bool
  description = "Whether the RDS deployment should be multi-az or single-az."
}

variable "rds_create_db_subnet_group" {
  type        = bool
  description = "Whether to create a database subnet group"
}

variable "rds_maintenance_window" {
  type        = string
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
}

variable "rds_backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
}

variable "rds_enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): alert, audit, error, general, listener, slowquery, trace, postgresql (PostgreSQL), upgrade (PostgreSQL)"
}
	
variable "rds_backup_retention_period" {
  type        = number
  description = "Numbers of days backup should be retained."
}

variable "rds_skip_final_snapshot" {
  type        = bool
  description = "When deleting the DB whether to create a final snapshot"
}

variable "rds_deletion_protection" {
  type        = bool
  description = "Deletion protection for DB. Have to disable deletion protection before deleting the DB."
}

variable "rds_performance_insights_enabled" {
  type        = bool
  description = "Amazon RDS Performance Insights is a database performance tuning and monitoring feature that helps you quickly assess the load on your database."
}

variable "rds_cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "The number of days to retain CloudWatch logs for the DB instance"
}

variable "rds_performance_insights_retention_period" {
  type        = number
  description = "The amount of time to retain Performance Insights data. The retention setting in the free tier is #default (7 days). To retain your performance data for longer, specify 1/24 months."
}

variable "rds_create_monitoring_role" {
  type        = bool
  description = "Ceate IAM role with a defined name that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
}

variable "rds_monitoring_interval" {
  type        = number
  description = " The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60"
}

variable "rds_delete_automated_backups" {
  type        = bool
  description = "Whether to delete the automated backups or not?"
}

variable "rds_iam_database_authentication_enabled" {
  type        = bool
  description = "Is IAM db authentication required or not?"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs"
}