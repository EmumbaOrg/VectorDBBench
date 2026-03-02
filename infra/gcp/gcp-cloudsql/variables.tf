variable "pg_module_name_prefix" {
  type        = string
  description = "Cloud Provider Module Name Prefix"
}

variable "pg_random_instance_name" {
  type        = bool
  description = "Random instance name of postgres instance"
}

variable "pg_project_id" {
  type        = string
  description = "Project ID of GCP project"
}

variable "pg_databse_version" {
  type        = string
  description = "POstgres version"
}

variable "pg_region" {
  type        = string
  description = "GCP region"
}

variable "pg_zone" {
  type        = string
  description = "GCP zone"
}

variable "pg_tier" {
  type        = string
  description = "DB instance type"
}

variable "pg_availability_type" {
  type        = string
  description = "DB instance availability type"
}

variable "pg_maintenance_window_day" {
  type        = number
  description = "DB instance maintenance window day"
}

variable "pg_maintenance_window_hour" {
  type        = number
  description = "DB instance maintenance window hour"
}

variable "pg_maintenance_window_update_track" {
  type        = string
  description = "DB instance maintenance window update track"
}  

variable "pg_deletion_protection" {
  type        = bool
  description = "DB instance deletion protection"
}

variable "pg_ipv4_configuration" {
  type        = bool
  description = "DB instance ipv4 configuration"
}

variable "pg_ssl_mode" {
  type        = string
  description = "DB instance ssl mode"
}

variable "pg_private_network" {
  type        = string
  description = "DB instance private network"
}  

variable "pg_allocated_ip_range" {
  type        = string
  description = "DB instance allocated ip range"
}

variable "pg_authorized_networks" {
  type        = string
  description = "DB instance authorized networks"
}

variable "pg_backup_configuration" {
  type        = bool
  description = "DB instance backup configuration"
}

variable "pg_start_time" {
  type        = string
  description = "DB instance start time"
}

variable "pg_backup_location" {
  type        = string
  description = "DB instance location"
}

variable "pg_point_in_time_recovery_enabled" {
  type        = bool
  description = "DB instance point in time recovery enabled"
}

variable "pg_transaction_log_retention_days" {
  description = "DB instance transaction log retention days"
}

variable "pg_retained_backups" {
  type        = number
  description = "DB instance retained backups"
}

variable "pg_retention_unit" {
  type        = string
  description = "DB instance retention unit"
}

variable "pg_db_charset" {
  type        = string
  description = "DB instance charset"
}

variable "pg_db_collation" {
  type        = string
  description = "DB instance collation"
}

variable "pg_user_name" {
  type        = string
  description = "DB instance user name"
}

variable "pg_user_password" {
  type        = string
  description = "DB instance user password"
}

