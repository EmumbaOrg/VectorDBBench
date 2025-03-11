locals {
  ingress_rules                       = var.sg_ingress
  db_name                             = join("_", [var.name_prefix, var.module_name_prefix])
  db_key_pair_name                    = join("_", [var.name_prefix, var.module_name_prefix, "key"])
  db_security_group_name              = join("_", [var.name_prefix, var.module_name_prefix, "sg"])
  common_tags = {
    Terraform           = "True"
    module_name_prefix  = var.module_name_prefix
    PartOfInfra         = "True"
    "Module"            = "EC2"
    "CreatedBy"         = "Vector-Benchmarking-IaC"
  }
}

module "db_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.2.1"
  name    = local.db_name

  ami                         = var.dbec2_ami
  instance_type               = var.dbec2_instance_type
  key_name                    = resource.aws_key_pair.db_key.key_name
  monitoring                  = var.dbec2_monitoring
  vpc_security_group_ids      = ["${aws_security_group.sg_db_server.id}"]
  subnet_id                   = var.pub_subnet_id 
  availability_zone           = var.az[0]
  associate_public_ip_address = var.dbec2_associate_public_ip_address

  #run bash script to prepare instance with required packages
  user_data                   = file("${path.module}/pgdb-setup.sh")

  tags = merge(local.common_tags, {
    Name = "${local.db_name}"
  })

}
resource "tls_private_key" "db_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "db_key" {
  key_name   = local.db_key_pair_name
  public_key = tls_private_key.db_private_key.public_key_openssh

  # To Generate and save private key () in current directory
  provisioner "local-exec" {
    command = <<-EOT
      sudo echo '${tls_private_key.db_private_key.private_key_pem}' > '${path.module}/${local.db_key_pair_name}.pem'
      sudo chmod 400 '${path.module}/${local.db_key_pair_name}.pem'
    EOT
  }
  tags = merge(local.common_tags, {
    Name = "${local.db_key_pair_name}"
  })
}

resource "aws_eip" "db_eip" {
  domain   = var.dbec2_eip_domain
  instance = module.db_instance.id
  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}_${var.module_name_prefix}_EIP"
  })
}

resource "aws_security_group" "sg_db_server" {
  name        = local.db_security_group_name
  description = "Security group for ${var.name_prefix} ${var.module_name_prefix} db host"
  vpc_id      = var.vpc_id #data.terraform_remote_state.vpc.outputs.vpc_id

  ingress{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

}
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}