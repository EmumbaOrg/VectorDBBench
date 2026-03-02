variable "name_prefix" {
  type        = string
  description = "Cloud Provider Name Prefix"
}

variable "dbce_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "dbce_subnet" {
  type        = string
  description = "subnetwork id"
}
variable "dbce_natip" {
  type        = string
  description = "nat ip address"
}

variable "dbce_image" {
  type        = string
  description = "compute engine image"
}

variable "dbce_size" {
  type        = string
  description = "size of compute engine"
}

variable "dbce_machine_type" {
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

variable "sshuser" {
  description = "username of compute engine"
  default = "gclouduser"
}