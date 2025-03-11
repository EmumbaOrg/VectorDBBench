locals {
  bench_name                = join("_", [var.name_prefix, var.module_name_prefix])
  bench_key_pair_name       = join("_", [var.name_prefix, var.module_name_prefix, "key"])
  bench_security_group_name = join("_", [var.name_prefix, var.module_name_prefix, "sg"])
  common_tags = {
    Terraform           = "True"
    module_name_prefix  = var.module_name_prefix
    PartOfInfra         = "True"
    "Module"            = "EC2"
    "CreatedBy"         = "Vector-Benchmarking-IaC"
  }
}

module "bench_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.2.1"
  name    = local.bench_name

  ami                         = var.benchec2_ami
  instance_type               = var.benchec2_instance_type
  key_name                    = resource.aws_key_pair.bench_key.key_name
  monitoring                  = var.benchec2_monitoring
  vpc_security_group_ids      = ["${aws_security_group.sg_bench_server.id}"]
  subnet_id                   = var.pub_subnet_id 
  availability_zone           = var.az[0]
  associate_public_ip_address = var.benchec2_associate_public_ip_address

  #run bash script to prepare instance with required environment 
  user_data                   = file("${path.module}/bench-setup.sh")

  root_block_device = [{
    volume_size = "200"
    volume_type = "gp3"
}]
  tags = merge(local.common_tags, {
    Name = "${local.bench_name}"
  })

}
resource "tls_private_key" "bench_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bench_key" {
  key_name   = local.bench_key_pair_name
  public_key = tls_private_key.bench_private_key.public_key_openssh
  
  # To Generate and save private key () in current directory
  provisioner "local-exec" {
    command = <<-EOT
      sudo echo '${tls_private_key.bench_private_key.private_key_pem}' > '${path.module}/${local.bench_key_pair_name}.pem'
      sudo chmod 400 '${path.module}/${local.bench_key_pair_name}.pem'
    EOT
  }
  tags = merge(local.common_tags, {
    Name = "${local.bench_key_pair_name}"
  })
}

resource "local_sensitive_file" "bench_pem_file" {
  filename = pathexpand("~/.ssh/${local.bench_key_pair_name}.pem")
  file_permission = "600"
  directory_permission = "700"
  content = tls_private_key.bench_private_key.private_key_pem
}

resource "aws_eip" "bench_eip" {
  domain   = var.benchec2_eip_domain
  instance = module.bench_instance.id
  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}_${var.module_name_prefix}_EIP"
  })
}

resource "aws_security_group" "sg_bench_server" {
  name        = local.bench_security_group_name
  description = "Security group for ${var.name_prefix} ${var.module_name_prefix} bench host"
  vpc_id      = var.vpc_id

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