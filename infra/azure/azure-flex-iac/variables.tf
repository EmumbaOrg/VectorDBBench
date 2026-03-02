variable "name_prefix" {
  type = string
  description = "Cloud Provider Name Prefix of the resource."
}

variable "flex_module_name_prefix" {
  type = string
  default     = "flexible_server"
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

variable "flex_dbuser" {
  type = string
  description = "username for Database"
}

variable "flex_dbpassword" {
  type = string
  description = "Password of Database."
}

variable "flex_publicaccess" {
  type = bool
  description = "Public access of database."
}

variable "flex_pgversion" {
  type = string
  description = "Password of Database."
}

variable "zone" {
  type = string
  description = "Password of Database."
}

variable "flex_server_storage" {
  type = string
  description = "Size of DB server storage in MBs"
}

variable "flex_server_sku" {
  type = string
  description = "Sku of flexible DB server"
}