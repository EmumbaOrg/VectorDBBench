variable "name_prefix" {
  type        = string
  description = "Cloud provider Name Prefix"
}

variable "pgrds_module_name_prefix" {
  type        = string
  default     = "aws"
  description = "Project Name"
}

variable "pgrds_engine" {
  type        = string
  description = "RDS engine to be launched."
}

variable "pgrds_engine_version" {
  type        = string
  description = "RDS engine version to be launched."
}

variable "pgrds_family" {
  type        = string
  description = "RDS family in parameter group"
}

variable "pgrds_major_engine_version" {
  type        = string
  description = "RDS major engine version to be set in option group"
}

variable "pgrds_instance_class" {
  type        = string
  description = "Instance for the RDS to be launched."
}

variable "pgrds_storage_type" {
  type        = string
  description = "Storage type"
}

variable "pgrds_allocated_storage" {
  type        = number
  description = "Storage to be allocated to RDS in GB"
}

variable "pgrds_pgrds_max_allocated_storage" {
  type        = number
  description = "Maximum storage to be allowed to RDS."
}

variable "pgrds_db_name" {
  type        = string
  description = "Database name"
}

variable "pgrds_db_user" {
  type        = string
  description = "Database user"
}

variable "pgrds_db_master_password" {
  type        = string
  description = "Database master password"
}

variable "pgrds_db_port" {
  type        = number
  description = "Port to be used for RDS"
}

variable "pgrds_az" {
  type        = list(string)
  description = "Availability zones"
}

variable "pgrds_multi_az" {
  type        = bool
  description = "Whether the RDS deployment should be multi-az or single-az."
}

variable "pgrds_create_db_subnet_group" {
  type        = bool
  description = "Whether to create a database subnet group"
}

variable "pgrds_maintenance_window" {
  type        = string
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
}

variable "pgrds_backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
}

variable "pgrds_enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): alert, audit, error, general, listener, slowquery, trace, postgresql (PostgreSQL), upgrade (PostgreSQL)"
}
	
variable "pgrds_backup_retention_period" {
  type        = number
  description = "Numbers of days backup should be retained."
}

variable "pgrds_skip_final_snapshot" {
  type        = bool
  description = "When deleting the DB whether to create a final snapshot"
}

variable "pgrds_deletion_protection" {
  type        = bool
  description = "Deletion protection for DB. Have to disable deletion protection before deleting the DB."
}

variable "pgrds_performance_insights_enabled" {
  type        = bool
  description = "Amazon RDS Performance Insights is a database performance tuning and monitoring feature that helps you quickly assess the load on your database."
}

variable "pgrds_cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "The number of days to retain CloudWatch logs for the DB instance"
}

variable "pgrds_performance_insights_retention_period" {
  type        = number
  description = "The amount of time to retain Performance Insights data. The retention setting in the free tier is Default (7 days). To retain your performance data for longer, specify 1/24 months."
}

variable "pgrds_create_monitoring_role" {
  type        = bool
  description = "Ceate IAM role with a defined name that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
}

variable "pgrds_monitoring_interval" {
  type        = number
  description = " The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60"
}

variable "pgrds_delete_automated_backups" {
  type        = bool
  description = "Whether to delete the automated backups or not?"
}

variable "pgrds_iam_database_authentication_enabled" {
  type        = bool
  description = "Is IAM db authentication required or not?"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs"
}

variable "pg_vpc_id" {
  type        = string
  description = "VPC ID of pgbenchmarking vpc"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "VPC ID of pgbenchmarking vpc"
}
