output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "pr_rt" {
  description = "Private route tables"
  value       = module.vpc.private_route_table_ids[0]
}

output "vpc_cidr_block" {
  description = "VPC CIDR address"
  value       = module.vpc.vpc_cidr_block
}

output "azs" {
  description = "VPC AZs"
  value       = module.vpc.azs
}

output "vpcregion" {
  description = "Region"
  value       = "eu-north-1"
}