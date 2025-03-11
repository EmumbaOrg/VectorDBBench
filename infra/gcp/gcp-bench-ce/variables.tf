variable "name_prefix" {
  type        = string
  description = "Cloud Provider Name Prefix"
}

variable "benchce_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "benchce_subnet" {
  type        = string
  description = "subnetwork id"
}

variable "benchce_natip" {
  type        = string
  description = "nat ip address"
}

variable "benchce_image" {
  type        = string
  description = "compute engine image"
}

variable "benchce_size" {
  type        = string
  description = "size of compute engine"
}

variable "benchce_machine_type" {
  type        = string
  description = "instance category of compute engine"
}

variable "benchce_zone" {
  type        = string
  description = "zone of compute engine"
}

variable "benchce_region" {
  type        = string
  description = "region of compute engine"
}

variable "sshuser" {
  description = "username of compute engine"
  default = "gclouduser"
}