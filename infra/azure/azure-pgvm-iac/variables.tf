# variable "name_prefix" {
#   default     = "azureiac"
#   description = "Prefix of the resource name."
# }

# variable "module_name_prefix" {
#   default     = "pgvm"
#   description = "Name of the module."
# }

# variable "location" {
#   default     = "eastus"
#   description = "Location of the resource."
# }

# variable "azurevnet-name" {
#   default     = "pgbench-vnet"
#   description = "Name of virtual network."
# }

# variable "resourcegroup_name" {
#   default     = "pgvector-benchmarking"
#   description = "Name of the resource group."
# }

# variable "vnet_subnet_address" {
#   #type        = list(string)
#   default     = ["10.0.0.0/24"] #, "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   description = "Address space of the vnet."
# }

# variable "zone" {
#   #default     = "1"
#   description = "Password of Database."
# }

# variable "subnet_id" {
#   #default     = "1"
#   description = "Subnet id."
# }

variable "name_prefix" {
  #default     = "azureiac"
  description = "Prefix of the resource name."
}

variable "dbvm_module_name_prefix" {
  #default     = "benchvm"
  description = "Name of the module."
}

variable "location" {
  #default     = "eastus"
  description = "Location of the resource."
}

# variable "azurevnet-name" {
#   #default     = "pgbench-vnet"
#   description = "Name of virtual network."
# }

variable "resourcegroup_name" {
  #default     = "pgvector-benchmarking"
  description = "Name of the resource group."
}

variable "vnet_subnet_address" {
  #type        = list(string)
  default     = ["10.0.0.0/24"] #, "10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "Address space of the vnet."
}

variable "zone" {
  #default     = "1"
  description = "Password of Database."
}

variable "subnet_id" {
  #default     = "1"
  description = "Subnet id."
}

variable "dbvm_ip_sku" {
  #default     = "Standard"
  description = "Sku for public ip."
}

variable "dbvm_public_ip_allocation_method" {
  #default     = "Static"
  description = "Allocation method for public ip."
}

variable "dbvm_private_ip_allocation_method" {
  #default     = "Dynamic"
  description = "Allocation method for private ip."
}

variable "dbvm_vm_type" {
  #default     = "Standard_D2s_v4"
  description = "Vm class/type as per official documentation."
}

variable "dbvm_vm_username" {
  #default     = "azureuser"
  description = "username for vm machine access."
}

variable "dbvm_vm_os_caching" {
  #default     = "ReadWrite"
  description = "OS caching mode ."
}

variable "dbvm_vm_disk_storage_account_type" {
  #default     = "Standard_LRS"
  description = "Disk Storage type for VM."
}

variable "dbvm_vm_disk_size" {
  #default     = "30"
  description = "VM disk size in GB."
}

variable "dbvm_vm_image_publisher" {
  #default     = "Canonical"
  description = "VM image publisher type."
}

variable "dbvm_vm_image_offer" {
  #default     = "0001-com-ubuntu-server-jammy"
  description = "VM image offer."
}

variable "dbvm_vm_image_sku" {
  #default     = "22_04-lts-gen2"
  description = "VM image sku."
}

variable "dbvm_vm_image_version" {
  #default     = "latest"
  description = "VM image version."
}