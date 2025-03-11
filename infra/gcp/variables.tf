# variable "subnet" {
#   type        = string
#   description = "subnetwork id"
# }
# variable "natip" {
#   type        = string
#   description = "nat ip address"
# }

variable "name_prefix" {
  type        = string
  description = "Name Prefix"
}

#=============================== CNET CONFIG =================================

# variable "name_prefix" {
#   type        = string
#   description = "Name Prefix"
# }

variable "cnet_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "cidr_range" {
  type        = string
  description = "IP CIDR RANGE OF CNET"
}

variable "cnet_zone" {
  type        = string
  description = "IP CIDR RANGE OF CNET"
}

variable "auto_subnet_create" {
  type        = bool
  description = "Auto create subnets for CNET"
}

variable "routing_mode" {
  type        = string
  description = "Routing mode for CNET"
}

variable "cnet_region" {
  type        = string
  description = "Module Name Prefix"
}

variable "module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "compute_address_provider" {
  type        = string
  description = "Provider for google compute address"
}

variable "compute_address_purpose" {
  type        = string
  description = "Purpose of compute address"
}

variable "compute_address_type" {
  type        = string
  description = "Address type of compute address"
}

variable "compute_address_prefix_length" {
  type        = number
  description = "Prefix length of compute address"
}

variable "compute_firewall_allow_protocol" {
  type        = list(string)
  description = "Network of compute address"
}

variable "compute_firewall_allow_ports" {
  type        = list(string)
  description = "Network of compute address"
}

variable "compute_firewall_source_ranges" {
  type        = list(string)
  description = "Network of compute address"
}

#================================== CLOUD SQL CONFIG =============================

variable "csql_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "csql_random_instance_name" {
  type        = bool
  description = "Random instance name of postgres instance"
}

variable "csql_project_id" {
  type        = string
  description = "Project ID of GCP project"
}

variable "csql_databse_version" {
  type        = string
  description = "POstgres version"
}

variable "csql_region" {
  type        = string
  description = "GCP region"
}

variable "csql_zone" {
  type        = string
  description = "GCP zone"
}

variable "csql_tier" {
  type        = string
  description = "DB instance type"
}

variable "csql_availability_type" {
  type        = string
  description = "DB instance availability type"
}

variable "csql_maintenance_window_day" {
  type        = number
  description = "DB instance maintenance window day"
}

variable "csql_maintenance_window_hour" {
  type        = number
  description = "DB instance maintenance window hour"
}

variable "csql_maintenance_window_update_track" {
  type        = string
  description = "DB instance maintenance window update track"
}  

variable "csql_deletion_protection" {
  type        = bool
  description = "DB instance deletion protection"
}

variable "csql_ipv4_configuration" {
    type        = bool
    description = "DB instance ipv4 configuration"
}

variable "csql_ssl_mode" {
    type        = string
    description = "DB instance ssl mode"
}

variable "csql_private_network" {
    type        = string
    description = "DB instance private network"
}  

variable "csql_allocated_ip_range" {
    type        = string
    description = "DB instance allocated ip range"
}

variable "csql_authorized_networks" {
    type        = string
    description = "DB instance authorized networks"
}

variable "csql_backup_configuration" {
    type        = bool
    description = "DB instance backup configuration"
}

variable "csql_start_time" {
    type        = string
    description = "DB instance start time"
}

variable "csql_backup_location" {
    type        = string
    description = "DB instance location"
}

variable "csql_point_in_time_recovery_enabled" {
    type        = bool
    description = "DB instance point in time recovery enabled"
}

variable "csql_transaction_log_retention_days" {
    #type        = null
    description = "DB instance transaction log retention days"
}

variable "csql_retained_backups" {
    type        = number
    description = "DB instance retained backups"
}

variable "csql_retention_unit" {
    type        = string
    description = "DB instance retention unit"
}

variable "csql_db_charset" {
    type        = string
    description = "DB instance charset"
}

variable "csql_db_collation" {
    type        = string
    description = "DB instance collation"
}


variable "csql_user_name" {
    type        = string
    description = "DB instance user name"
}

variable "csql_user_password" {
    type        = string
    description = "DB instance user password"
}


#=============================== BENCH CE CONFIG =================================

variable "benchce_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "image" {
  type        = string
  description = "compute engine image"
}

variable "size" {
  type        = string
  description = "size of compute engine"
}

variable "type" {
  type        = string
  description = "instance category of compute engine"
}

variable "benchce_zone" {
  type        = string
  description = "zone of compute engine"
}

variable "benchce_region" {
  type        = string
  description = "region of compute engine"
}

#=============================== DB CE CONFIG =================================

variable "dbce_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "dbce_image" {
  type        = string
  description = "compute engine image"
}

variable "dbce_size" {
  type        = string
  description = "size of compute engine"
}

variable "dbce_type" {
  type        = string
  description = "instance category of compute engine"
}

variable "dbce_zone" {
  type        = string
  description = "zone of compute engine"
}

variable "dbce_region" {
  type        = string
  description = "region of compute engine"
}
