###################### GENERAL VARIABLES ############################

variable "name_prefix" {
  description = "Cloud provider prefix name of the resource."
  type = string
}

variable "location" {
  description = "Region for deployment."
  type = string
}

variable "zone" {
  description = "Zone of selected region."
  type = string
}

variable "resourcegroup_name" {
  description = "Name of the resource group."
  type = string
}

####################### VNET VARIABLES ##############################

variable "vnet_module_name_prefix" {
  type = string
  description = "Module Prefix name."
}

variable "vnet_ipaddress" {
  description = "Address space of the vnet."
}

variable "vnet_subnet_address" {
  default     = ["10.0.0.0/24"]
  description = "subnets of the vnet."
}

####################### FLEXIBLE DB VARIABLES #######################

variable "flex_module_name_prefix" {
  type = string
  description = "Name of the flexible DB server module."
}

variable "flex_server_storage" {
  type = number
  description = "Size of DB server storage in MBs"
}

variable "flex_server_sku" {
  type = string
  description = "Sku of flexible DB server"
}

variable "flex_dbuser" {
  type = string
  description = "username for flexible Database"
}

variable "flex_dbpassword" {
  type = string
  description = "Password of flexible Database."
}

variable "flex_publicaccess" {
  type = bool
  description = "Public access of database."
}

variable "flex_pgversion" {
  type = string
  description = "PostGres version."
}

######################### BENCH VM VARIABLES ##########################
variable "benchvm_module_name_prefix" {
  type = string
  description = "Name of the module."
}

variable "ip_sku" {
  type = string
  description = "Sku for public ip."
}

variable "public_ip_allocation_method" {
  type = string
  description = "Allocation method for public ip."
}

variable "private_ip_allocation_method" {
  type = string
  description = "Allocation method for private ip."
}

variable "vm_type" {
  type = string
  description = "Vm class/type as per official documentation."
}

variable "vm_username" {
  type = string
  description = "username for vm machine access."
}

variable "vm_os_caching" {
  type = string
  description = "OS caching mode ."
}

variable "vm_disk_storage_account_type" {
  type = string
  description = "Disk Storage type for VM."
}

variable "vm_disk_size" {
  type = string
  description = "VM disk size in GB."
}

variable "vm_image_publisher" {
  type = string
  description = "VM image publisher type."
}

variable "vm_image_offer" {
  type = string
  description = "VM image offer."
}

variable "vm_image_sku" {
  type = string
  description = "VM image sku."
}

variable "vm_image_version" {
  type = string
  description = "VM image version."
}

######################## DB VM VARIABLES #############################

variable "dbvm_module_name_prefix" {
  type = string
  description = "Name of the module."
}

variable "dbvm_ip_sku" {
  type = string
  description = "Sku for public ip."
}

variable "dbvm_public_ip_allocation_method" {
  description = "Allocation method for public ip."
  type = string
}

variable "dbvm_private_ip_allocation_method" {
  description = "Allocation method for private ip."
  type = string
}

variable "dbvm_vm_type" {
  description = "Vm class/type as per official documentation."
  type = string
}

variable "dbvm_vm_username" {
  description = "username for vm machine access."
  type = string
}

variable "dbvm_vm_os_caching" {
  description = "OS caching mode ."
  type = string
}

variable "dbvm_vm_disk_storage_account_type" {
  description = "Disk Storage type for VM."
  type = string
}

variable "dbvm_vm_disk_size" {
  description = "VM disk size in GB."
  type = string
}

variable "dbvm_vm_image_publisher" {
  description = "VM image publisher type."
  type = string
}

variable "dbvm_vm_image_offer" {
  description = "VM image offer."
  type = string
}

variable "dbvm_vm_image_sku" {
  description = "VM image sku."
  type = string
}

variable "dbvm_vm_image_version" {
  description = "VM image version."
  type = string
}