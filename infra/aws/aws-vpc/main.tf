# LOCAL VARIABLES
locals {
  common_tags = {
    "Name"        = join("-", [var.name_prefix, var.vpc_module_name_prefix])
    "Environment" = var.vpc_module_name_prefix
    "Module"      = "VPC"
    "Terraform"   = "true"
    "CreatedBy"   = "Vector-Benchmarking-IaC"
    "PartOfInfra" = "true"
  }
}

# VPC MODULE
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name    = join("-", [var.name_prefix, var.vpc_module_name_prefix])

  cidr                 = var.vpc_cidr
  enable_dns_hostnames = var.vpc_enable_dns_hostnames
  enable_dns_support   = var.vpc_enable_dns_support

  azs                  = var.vpc_azs
  public_subnets       = var.vpc_public_subnet_cidr_blocks
  private_subnets      = var.vpc_private_subnet_cidr_blocks

  create_igw           = var.vpc_create_igw
  enable_nat_gateway   = var.vpc_enable_nat_gateway
  single_nat_gateway   = var.vpc_single_nat_gateway

  # Tags from local variables
  tags                 = local.common_tags

  private_subnet_tags = {
    "Type"             = "Private"
  }

  public_subnet_tags = {
    "Type"             = "Public"
  }

}
resource "aws_ec2_tag" "private_subnet_tag" {
  count = length(module.vpc.private_subnets) 
  resource_id    = module.vpc.private_subnets[count.index]
  key            = "Name"
  value          = join("-", [local.common_tags.Name, "Private-Sub", count.index])
}

resource "aws_ec2_tag" "public_subnet_tag" {
  count = length(module.vpc.public_subnets) 
  resource_id    = module.vpc.public_subnets[count.index]
  key            = "Name"
  value          = join("-", [local.common_tags.Name, "Public-Sub", count.index])
}

resource "aws_ec2_tag" "private_route_table" {
  count = length(module.vpc.private_route_table_ids)
  resource_id = module.vpc.private_route_table_ids[count.index]
  key            = "Name"
  value          = join("-", [local.common_tags.Name, "Private-rt", count.index])
}

resource "aws_ec2_tag" "public_route_table" {
  count = length(module.vpc.public_route_table_ids)
  resource_id = module.vpc.public_route_table_ids[count.index]
  key            = "Name"
  value          = join("-", [local.common_tags.Name, "Public-rt", count.index])
}

resource "aws_ec2_tag" "aws_internet_gateway" {
  #count = length(module.vpc.igw_id)
  resource_id = module.vpc.igw_id#[count.index]
  key            = "Name"
  value          = join("-", [local.common_tags.Name, "IGW"])
}

resource "aws_ec2_tag" "nat_gateway" {
  count = length(module.vpc.natgw_ids)
  resource_id = module.vpc.natgw_ids[count.index]
  key            = "Name"
  value          = join("-", [local.common_tags.Name, "NATGW", count.index])
}