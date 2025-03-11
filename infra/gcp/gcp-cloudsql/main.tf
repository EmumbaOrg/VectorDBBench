data "google_compute_network" "gcp-pgbench-net" {
  name = "gcp-pgbench-net"
}

module "pgcloudsql" {
  source  = "terraform-google-modules/sql-db/google//modules/postgresql"
  version = "~> 20.0"

  name                            = var.pg_module_name_prefix 
  random_instance_name            = var.pg_random_instance_name 
  project_id                      = var.pg_project_id 
  database_version                = var.pg_databse_version 
  region                          = var.pg_region
  zone                            = var.pg_zone 

  # DB configurations
  tier                            = var.pg_tier 
  availability_type               = var.pg_availability_type 
  maintenance_window_day          = var.pg_maintenance_window_day 
  maintenance_window_hour         = var.pg_maintenance_window_hour 
  maintenance_window_update_track = var.pg_maintenance_window_update_track 
  disk_size = 100
  disk_type = "PD_SSD"
  edition = "ENTERPRISE"
  enable_default_db = true
  instance_type = "CLOUD_SQL_INSTANCE"
  data_cache_enabled = false
  disk_autoresize = false
  deletion_protection = var.pg_deletion_protection 

  database_flags = [{ name = "autovacuum", value = "off" }]

  user_labels = {
    createdfor = "pgvector-benchmarking"
    createdby  = "terraform"
  }

  ip_configuration = {
    ipv4_enabled       = var.pg_ipv4_configuration 
    ssl_mode        = var.pg_ssl_mode 
    private_network    = var.pg_private_network 
    #private_network    = data.google_compute_network.gcp-pgbench-net.id
    allocated_ip_range = var.pg_allocated_ip_range 
    authorized_networks = [
      {
        name  = "pgvector-benchmarking-cidr" 
        value = var.pg_authorized_networks 
      },
    ]
  }

  backup_configuration = {
    enabled                        = var.pg_backup_configuration
    start_time                     = var.pg_start_time
    location                       = var.pg_backup_location 
    point_in_time_recovery_enabled = var.pg_point_in_time_recovery_enabled 
    transaction_log_retention_days = var.pg_transaction_log_retention_days 
    retained_backups               = var.pg_retained_backups 
    retention_unit                 = var.pg_retention_unit 
  }

  #db_name      = "postgres" 
  db_charset   = var.pg_db_charset 
  db_collation = var.pg_db_collation 

  user_name     = var.pg_user_name 
  user_password = var.pg_user_password 
}