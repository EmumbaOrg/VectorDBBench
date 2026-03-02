variable "name_prefix" {
  type        = string
  description = "Cloud Provider Name Prefix"
}

variable "cnet_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "cnet_cidr_range" {
  type        = string
  description = "IP CIDR RANGE OF CNET"
}

variable "cnet_auto_subnet_create" {
  type        = bool
  description = "Auto create subnets for CNET"
}

variable "cnet_routing_mode" {
  type        = string
  description = "Routing mode for CNET"
}

variable "cnet_region" {
  type        = string
  description = "Module Name Prefix"
}

variable "cnet_compute_address_provider" {
  type        = string
  description = "Provider for google compute address"
}

variable "cnet_compute_address_purpose" {
  type        = string
  description = "Purpose of compute address"
}

variable "cnet_compute_address_type" {
  type        = string
  description = "Address type of compute address"
}

variable "cnet_compute_address_prefix_length" {
  type        = number
  description = "Prefix length of compute address"
}

variable "cnet_compute_firewall_allow_protocol" {
  type        = list(string)
  description = "Network of compute address"
}

variable "cnet_compute_firewall_allow_ports" {
  type        = list(string)
  description = "Network of compute address"
}

variable "cnet_compute_firewall_source_ranges" {
  type        = list(string)
  description = "Network of compute address"
}

