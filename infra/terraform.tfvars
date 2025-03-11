#+++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++ AWS CONFIG +++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++

#region and zone
aws_region = "us-east-1"
aws_az     = ["us-east-1a", "us-east-1b"]

#=============================================
#vpc module config
#=============================================
aws_name_prefix                = "aws"       
aws_vpc_module_name_prefix     = "pgbench_vpc"
aws_vpc_cidr                   = "10.0.0.0/16"
aws_create_igw                 = true
aws_enable_nat_gateway         = true
aws_single_nat_gateway         = true
aws_number_of_priv_cidr        = 1
aws_number_of_pub_cidr         = 1
aws_private_subnet_cidr_blocks = ["10.0.4.0/24", "10.0.5.0/24"]
aws_public_subnet_cidr_blocks  = ["10.0.0.0/24", "10.0.1.0/24"]
aws_enable_dns_hostnames       = true
aws_enable_dns_support         = true

#=============================================
#Bench EC2 module config
#=============================================
aws_bench_module_name_prefix        = "ubuntu_bench_ec2"
aws_ec2_monitoring                  = true
aws_ec2_ami                         = "ami-005fc0f236362e99f"
aws_ec2_instance_type               = "m7i.2xlarge"
aws_ec2_associate_public_ip_address = true
aws_ec2_eip_domain                  = "vpc"
aws_ec2_username                    = "ubuntu"

#=============================================
#EC2 DB module config
#=============================================
aws_db_module_name_prefix             = "postgres_db_ec2"
aws_dbec2_monitoring                  = true
aws_dbec2_ami                         = "ami-005fc0f236362e99f"
aws_dbec2_instance_type               = "m7i.2xlarge"
aws_dbec2_associate_public_ip_address = true
aws_dbec2_eip_domain                  = "vpc"
aws_dbec2_username                    = "ubuntu"

#=============================================
#RDS module config
#=============================================
aws_rds_module_name_prefix     = "rds-pg-customdataset"
aws_rds_engine                 = "postgres"
aws_rds_engine_version         = "16.4"
aws_rds_family                 = "postgres16"
aws_rds_major_engine_version   = "16"
aws_rds_instance_class         = "db.m6i.2xlarge"
aws_rds_storage_type           = "gp3"
aws_rds_allocated_storage      = 300
aws_rds_max_allocated_storage  = 400
aws_rds_db_name                = "postgres"
aws_rds_db_user                = "postgres"
aws_rds_db_master_password     = "postgres"
aws_rds_db_port                = 5432
aws_rds_az                     = ["us-east-1a"]
aws_rds_multi_az               = false
aws_rds_create_db_subnet_group = true
aws_rds_maintenance_window     = null
aws_rds_backup_window          = null
#aws_rds_enabled_cloudwatch_logs_exports = [ "postgresql", "upgrade" ]
aws_rds_backup_retention_period                = 7
aws_rds_skip_final_snapshot                    = true
aws_rds_deletion_protection                    = false
aws_rds_performance_insights_enabled           = true
aws_rds_cloudwatch_log_group_retention_in_days = 7
aws_rds_performance_insights_retention_period  = 7
aws_rds_create_monitoring_role                 = true
aws_rds_monitoring_interval                    = 60
aws_rds_delete_automated_backups               = true
aws_rds_iam_database_authentication_enabled    = false
aws_private_subnet_ids                         = []

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++ AZURE CONFIG +++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++

azure_name_prefix        = "azureiac"
azure_location           = "eastus"
azure_zone               = "1"
azure_resourcegroup_name = "pgvector-benchmarking"              #prerequisite required: change this variable with resource group name created manually

#==============================================
# vnet module config
#==============================================
azure_vnet_module_name_prefix = "pgbench-vnet"
azure_vnet_ipaddress          = ["10.0.0.0/16"]
azure_vnet_subnet_address     = ["10.0.0.0/24"]

#==============================================
#flex db module config
#==============================================
azure_flex_module_name_prefix = "flexible-server"
azure_flex_server_storage     = 262144
azure_flex_server_sku         = "GP_Standard_D4ds_v5"
azure_flex_dbuser             = "postgres"
azure_flex_dbpassword         = "postgres"
azure_flex_publicaccess       = true
azure_flex_pgversion          = "16"

#==============================================
#bench vm module config
#==============================================
azure_benchvm_module_name_prefix   = "benchvm"
azure_ip_sku                       = "Standard"
azure_public_ip_allocation_method  = "Static"
azure_private_ip_allocation_method = "Dynamic"
azure_vm_type                      = "Standard_D8ds_v5"
azure_vm_username                  = "azureuser"
azure_vm_os_caching                = "ReadWrite"
azure_vm_disk_storage_account_type = "Premium_LRS"
azure_vm_disk_size                 = "200"
azure_vm_image_publisher           = "Canonical"
azure_vm_image_offer               = "0001-com-ubuntu-server-jammy"
azure_vm_image_sku                 = "22_04-lts-gen2"
azure_vm_image_version             = "latest"

#==============================================
#db vm module config
#==============================================
azure_dbvm_module_name_prefix           = "selfmanaged-pgvm"
azure_dbvm_ip_sku                       = "Standard"
azure_dbvm_public_ip_allocation_method  = "Static"
azure_dbvm_private_ip_allocation_method = "Dynamic"
azure_dbvm_vm_type                      = "Standard_D8ds_v5"
azure_dbvm_vm_username                  = "azureuser"
azure_dbvm_vm_os_caching                = "ReadWrite"
azure_dbvm_vm_disk_storage_account_type = "Premium_LRS"
azure_dbvm_vm_disk_size                 = "120"
azure_dbvm_vm_image_publisher           = "Canonical"
azure_dbvm_vm_image_offer               = "0001-com-ubuntu-server-jammy"
azure_dbvm_vm_image_sku                 = "22_04-lts-gen2"
azure_dbvm_vm_image_version             = "latest"

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++ GCP CONFIG +++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++

gcp_name_prefix        = "gcp"
gcp_module_name_prefix = "pgbench"

#===============================================
#GCP cnet module config
#===============================================
gcp_cnet_region                          = "us-west1"
gcp_cnet_zone                            = "us-west1-a"
gcp_cnet_cidr_range                      = "192.168.24.0/24"
gcp_cnet_auto_subnet_create              = false
gcp_cnet_compute_address_provider        = "google"
gcp_cnet_compute_address_purpose         = "VPC_PEERING"
gcp_cnet_compute_address_type            = "INTERNAL"
gcp_cnet_compute_address_prefix_length   = 16
gcp_cnet_compute_firewall_allow_ports    = ["22", "5432"]
gcp_cnet_compute_firewall_allow_protocol = ["tcp"]
gcp_cnet_compute_firewall_source_ranges  = ["0.0.0.0/0"]
gcp_cnet_module_name_prefix              = "cnet"
gcp_cnet_routing_mode                    = "REGIONAL"

#===============================================
#GCP cloudsql config
#===============================================
gcp_csql_module_name_prefix              = "cloudsql"
gcp_csql_random_instance_name            = false
gcp_csql_project_id                      = "pgvector-benchmarking"            #prerequisite required: change this variable with manually created project name
gcp_csql_databse_version                 = "POSTGRES_16"
gcp_csql_region                          = "us-west1"
gcp_csql_zone                            = "us-west1-a"
gcp_csql_tier                            = "db-custom-2-8192"                 #change SKU of DB per requirement
gcp_csql_availability_type               = "REGIONAL"
gcp_csql_maintenance_window_day          = 7
gcp_csql_maintenance_window_hour         = 12
gcp_csql_maintenance_window_update_track = "stable"
gcp_csql_deletion_protection             = false
gcp_csql_ipv4_configuration              = true
gcp_csql_ssl_mode                        = "ENCRYPTED_ONLY"
gcp_csql_private_network                 = null
gcp_csql_allocated_ip_range              = null
gcp_csql_authorized_networks             = "0.0.0.0/0"
gcp_csql_backup_configuration            = false
gcp_csql_start_time                      = "20:55"
gcp_csql_backup_location                 = null
gcp_csql_point_in_time_recovery_enabled  = false
gcp_csql_transaction_log_retention_days  = null
gcp_csql_retained_backups                = 1
gcp_csql_retention_unit                  = "COUNT"
gcp_csql_db_charset                      = "UTF8"
gcp_csql_db_collation                    = "en_US.UTF8"
gcp_csql_user_name                       = "postgres"
gcp_csql_user_password                   = "postgres"

#===============================================
#gcp benchce module config
#===============================================
gcp_benchce_region = "us-west1"
gcp_benchce_zone   = "us-west1-a"
#gcp_benchce_username = "value"
#gcp_benchce_natip = "value"
gcp_benchce_image        = "ubuntu-os-cloud/ubuntu-2204-lts"
gcp_benchce_size         = 200
gcp_benchce_machine_type = "e2-standard-2" 

#===============================================
#gcp dbce module config
#===============================================
gcp_dbce_module_name_prefix = "dbce"
gcp_dbce_region             = "us-west1"
gcp_dbce_zone               = "us-west1-a"
#gcp_dbce_username = "value"
#gcp_benchce_natip = "value"
gcp_dbce_image        = "ubuntu-os-cloud/ubuntu-2204-lts"
gcp_dbce_size         = 50
gcp_dbce_machine_type = "e2-standard-2"