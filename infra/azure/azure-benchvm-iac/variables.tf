variable "name_prefix" {
  type = string
  description = "Prefix of the resource name."
}

variable "benchvm_module_name_prefix" {
  type = string
  description = "Name of the module."
}

variable "location" {
  type = string
  description = "Location of the resource."
}

variable "resourcegroup_name" {
  type = string
  description = "Name of the resource group."
}

variable "vnet_subnet_address" {
  default     = ["10.0.0.0/24"]
  description = "Address space of the vnet."
}

variable "zone" {
  type = string
  description = "Password of Database."
}

variable "subnet_id" {
  description = "Subnet id."
}

variable "benchvm_ip_sku" {
  type = string
  description = "Sku for public ip."
}

variable "benchvm_public_ip_allocation_method" {
  type = string
  description = "Allocation method for public ip."
}

variable "benchvm_private_ip_allocation_method" {
  type = string
  description = "Allocation method for private ip."
}

variable "benchvm_type" {
  type = string
  description = "Vm class/type as per official documentation."
}

variable "benchvm_username" {
  type = string
  description = "username for vm machine access."
}

variable "benchvm_os_caching" {
  type = string
  description = "OS caching mode."
}

variable "benchvm_disk_storage_account_type" {
  type = string
  description = "Disk Storage type for VM."
}

variable "benchvm_disk_size" {
  type = string
  description = "VM disk size in GB."
}

variable "benchvm_image_publisher" {
  type = string
  description = "VM image publisher type."
}

variable "benchvm_image_offer" {
  type = string
  description = "VM image offer."
}

variable "benchvm_image_sku" {
  type = string
  description = "VM image sku."
}

variable "benchvm_image_version" {
  type = string
  description = "VM image version."
}