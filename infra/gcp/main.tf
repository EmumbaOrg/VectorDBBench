module "pg_cnet" {
  source      = "./gcp-cnet"

  cnet_module_name_prefix = var.module_name_prefix
  name_prefix = var.name_prefix
  cnet_region = var.cnet_region
  cnet_cidr_range = var.cidr_range
  cnet_auto_subnet_create = var.auto_subnet_create
  cnet_routing_mode = var.routing_mode
  cnet_compute_address_provider = var.compute_address_provider
  cnet_compute_address_purpose = var.compute_address_purpose
  cnet_compute_address_type = var.compute_address_type
  cnet_compute_address_prefix_length = var.compute_address_prefix_length
  cnet_compute_firewall_allow_protocol = var.compute_firewall_allow_protocol
  cnet_compute_firewall_allow_ports = var.compute_firewall_allow_ports
  cnet_compute_firewall_source_ranges = var.compute_firewall_source_ranges
 }

#module "pg_cloudsql" {
 #source      = "./gcp-cloudsql"
 #depends_on = [ module.pg_cnet ]

# pg_module_name_prefix = var.csql_module_name_prefix
# pg_random_instance_name = var.csql_random_instance_name
# pg_project_id = var.csql_project_id
# pg_databse_version = var.csql_databse_version
# pg_region = var.csql_region
# pg_zone = var.csql_zone
# pg_tier = var.csql_tier
# pg_availability_type = var.csql_availability_type
# pg_maintenance_window_day = var.csql_maintenance_window_day
# pg_maintenance_window_hour = var.csql_maintenance_window_hour
# pg_maintenance_window_update_track = var.csql_maintenance_window_update_track
# pg_deletion_protection = var.csql_deletion_protection
# pg_ipv4_configuration = var.csql_ipv4_configuration
# pg_ssl_mode = var.csql_ssl_mode
# pg_private_network = var.csql_private_network
# pg_allocated_ip_range = var.csql_allocated_ip_range
# pg_authorized_networks = var.csql_authorized_networks
# pg_backup_configuration = var.csql_backup_configuration
# pg_start_time = var.csql_start_time
# pg_backup_location = var.csql_backup_location
# pg_point_in_time_recovery_enabled = var.csql_point_in_time_recovery_enabled
# pg_transaction_log_retention_days = var.csql_transaction_log_retention_days
# pg_retained_backups = var.csql_retained_backups
# pg_retention_unit = var.csql_retention_unit
# pg_db_charset = var.csql_db_charset
# pg_db_collation = var.csql_db_collation
# pg_user_name = var.csql_user_name
# pg_user_password = var.csql_user_password
#}

module "bench_comp_eng" {
   source      = "./gcp-bench-ce"
   depends_on = [ module.pg_cnet ]
   benchce_subnet = module.pg_cnet.subnet_id
   name_prefix = var.name_prefix
   benchce_module_name_prefix = var.module_name_prefix
   benchce_natip = module.pg_cnet.cnet_ip_external_benchce
   benchce_image = var.image
   benchce_size = var.size
   benchce_machine_type = var.type
   benchce_region = var.benchce_region
   benchce_zone = var.benchce_zone
}

module "db_comp_eng" {
   source      = "./gcp-db-ce"
   depends_on = [ module.pg_cnet ]
   name_prefix = var.name_prefix
   dbce_subnet = module.pg_cnet.subnet_id
   dbce_module_name_prefix = var.dbce_module_name_prefix
   dbce_natip = module.pg_cnet.cnet_ip_external_dbce
   dbce_image = var.dbce_image
   dbce_size = var.dbce_size
   dbce_machine_type = var.dbce_type
   dbce_region = var.dbce_region
   dbce_zone = var.dbce_zone
 }