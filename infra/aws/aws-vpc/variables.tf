variable "name_prefix" {
  type        = string
  description = "Project Name"
}

variable "vpc_module_name_prefix" {
  type        = string
  description = "Module Name Prefix"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
}

variable "vpc_enable_dns_support" {
  type        = bool
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
}

variable "vpc_azs" {
  type        = list(string)
  description = "Availability zones"
}

variable "vpc_public_subnet_cidr_blocks" {
  type        = list(string)
  description = "Public subnets CIDR blocks"
}

variable "vpc_private_subnet_cidr_blocks" {
  type        = list(string)
  description = "Private subnets CIDR blocks"
}

variable "vpc_create_igw" {
  type        = bool
  description = "A boolean flag to create internet gateway in the VPC. Defaults true."
}

variable "vpc_enable_nat_gateway" {
  type        = bool
  description = "A boolean flag to create NAT gateway for private subnets. Defaults true."
}

variable "vpc_single_nat_gateway" {
  type        = bool
  description = "Enable only one NAT gateway. Defaults true."
}

variable "vpc_number_of_priv_cidr" {
  type        = string
  description = "Define Number of private subnets"
}

variable "vpc_number_of_pub_cidr" {
  type        = string
  description = "Define Number of public subnets"
}

variable "vpcregion" {
  type        = string
  description = "Region"
}