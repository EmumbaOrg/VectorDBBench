variable "name_prefix" {
  type = string
  description = "Cloud Provider Name Prefix of the resource."
}

variable "vnet_module_name_prefix" {
  type = string
  description = "Module Prefix name."
}

variable "location" {
  type = string
  description = "Location of the resource."
}

variable "resourcegroup_name" {
  type = string
  description = "Name of the resource group."
}

variable "vnet_ipaddress" {
  description = "Address space of the vnet."
}

variable "vnet_subnet_address" {
  description = "Address of the subnet."
}

variable "zone" {
  type = string
  description = "Zone in which resources will be deployed."
}