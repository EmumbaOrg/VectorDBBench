
##################################################################################
# MODULES
##################################################################################

module "azure_vnet" {
  source                  = "./azure-vnet"
  zone                    = var.zone
  name_prefix             = var.name_prefix
  location                = var.location
  vnet_ipaddress          = var.vnet_ipaddress
  resourcegroup_name      = var.resourcegroup_name
  vnet_module_name_prefix = var.vnet_module_name_prefix
  vnet_subnet_address     = var.vnet_subnet_address
}

module "azure_pgflex" {
  depends_on              = [module.azure_vnet]
  source                  = "./azure-flex-iac"
  zone                    = var.zone
  name_prefix             = var.name_prefix
  flex_module_name_prefix = var.flex_module_name_prefix
  location                = var.location
  resourcegroup_name      = var.resourcegroup_name
  flex_dbuser             = var.flex_dbuser
  flex_dbpassword         = var.flex_dbpassword
  flex_publicaccess       = var.flex_publicaccess
  flex_pgversion          = var.flex_pgversion
  flex_server_sku         = var.flex_server_sku
  flex_server_storage     = var.flex_server_storage
}

module "azure_benchvm" {
   depends_on                           = [module.azure_vnet]
   source                               = "./azure-benchvm-iac"
   name_prefix                          = var.name_prefix
   zone                                 = var.zone
   location                             = var.location
   resourcegroup_name                   = var.resourcegroup_name
   subnet_id                            = module.azure_vnet.vnet_subnet_id
   benchvm_module_name_prefix           = var.benchvm_module_name_prefix
   benchvm_ip_sku                       = var.ip_sku
   benchvm_disk_size                    = var.vm_disk_size
   benchvm_disk_storage_account_type    = var.vm_disk_storage_account_type
   benchvm_public_ip_allocation_method  = var.public_ip_allocation_method
   benchvm_private_ip_allocation_method = var.private_ip_allocation_method
   benchvm_type                         = var.vm_type
   benchvm_username                     = var.vm_username
   benchvm_os_caching                   = var.vm_os_caching
   benchvm_image_publisher              = var.vm_image_publisher
   benchvm_image_offer                  = var.vm_image_offer
   benchvm_image_sku                    = var.vm_image_sku
   benchvm_image_version                = var.vm_image_version
 }

module "azure_pgvm" {
   depends_on                        = [module.azure_vnet]
   source                            = "./azure-pgvm-iac"
   zone                              = var.zone
   location                          = var.location
   resourcegroup_name                = var.resourcegroup_name
   subnet_id                         = module.azure_vnet.vnet_subnet_id
   name_prefix                       = var.name_prefix
   dbvm_module_name_prefix           = var.dbvm_module_name_prefix
   dbvm_ip_sku                       = var.ip_sku
   dbvm_public_ip_allocation_method  = var.public_ip_allocation_method
   dbvm_private_ip_allocation_method = var.private_ip_allocation_method
   dbvm_vm_type                      = var.vm_type
   dbvm_vm_username                  = var.vm_username
   dbvm_vm_os_caching                = var.vm_os_caching
   dbvm_vm_disk_size                 = var.vm_disk_size
   dbvm_vm_disk_storage_account_type = var.vm_disk_storage_account_type
   dbvm_vm_image_publisher           = var.vm_image_publisher
   dbvm_vm_image_offer               = var.vm_image_offer
   dbvm_vm_image_sku                 = var.vm_image_sku
   dbvm_vm_image_version             = var.vm_image_version
}
