variable "name_prefix" {
  description = "Cloud provider Name Prefix"
}

variable "module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "region" {
  type        = string
  description = "Region for deployment"
}

variable "az" {
  type        = list(string)
  description = "Availability zones of selected region"
}

variable "pub_subnet_id" {
  type        = string
  description = "Public Subnet ID"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "dbec2_monitoring" {
  type        = bool
  description = "Enable/disable detailed monitoring for ec2"
}

variable "dbec2_ami" {
  type        = string
  description = "AMI to use for the instance."
}

variable "dbec2_instance_type" {
  type        = string
  description = "The instance type to use for the instance. Updates to this field will trigger a stop/start of the EC2 instance."
}

variable "dbec2_associate_public_ip_address" {
  type        = bool
  description = "Whether to associate a public IP address with an instance in a VPC."
}

variable "dbec2_eip_domain" {
  type        = string
  description = "Indicates if this EIP is for use in VPC."
}

variable "sg_ingress" {
  type        = list(any)
  description = "Security group for ingress traffic"
}

variable "dbec2_username" {
  type        = string
  description = "Bench Ec2 username"
}
