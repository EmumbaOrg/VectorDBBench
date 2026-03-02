resource "azurerm_public_ip" "bench_public_ip" {
  count               = var.zone != null ? 1 : 0
  name                = "${var.name_prefix}_${var.benchvm_module_name_prefix}_public_ip" 
  resource_group_name = var.resourcegroup_name
  location            = var.location
  sku                 = var.benchvm_ip_sku
  allocation_method   = var.benchvm_public_ip_allocation_method
  zones = var.zone ? [element(["1", "2", "3"], count.index + 1)] : []

  tags = {
    "Terraform"           = "True"
    "PartOfInfra"         = "True"
    "Module"              = "VM"
    "CreatedBy"           = "Vector-Benchmarking-IaC"
  }
}

resource "azurerm_network_interface" "bench-netinterface" {
  name                            = "${var.name_prefix}_${var.benchvm_module_name_prefix}_nic"
  location                        = var.location
  resource_group_name             = var.resourcegroup_name

  ip_configuration {
    name                          = "${var.name_prefix}_${var.benchvm_module_name_prefix}_ipconfig"
    subnet_id                     = var.subnet_id[0] 
    private_ip_address_allocation = var.benchvm_private_ip_allocation_method
    public_ip_address_id          = azurerm_public_ip.bench_public_ip[0].id
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Store the Private Key Locally 
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/benchvm_key.pem"

  provisioner "local-exec" {
    command = "sudo chmod 600 ${path.module}/benchvm_key.pem"
  }
}

resource "azurerm_linux_virtual_machine" "pgbench-machine" {
  name                            = "${var.name_prefix}_${var.benchvm_module_name_prefix}_machine"
  computer_name                   = var.benchvm_module_name_prefix
  resource_group_name             = var.resourcegroup_name
  location                        = var.location
  size                            = var.benchvm_type
  admin_username                  = var.benchvm_username
  zone                            = var.zone
  network_interface_ids           = [
    azurerm_network_interface.bench-netinterface.id,
  ]

  admin_ssh_key {
    username   = var.benchvm_username
    public_key = tls_private_key.ssh_key.public_key_openssh  
  }

  custom_data = base64encode(file("${path.module}/bench-setup.sh"))

  os_disk {
    caching                       = var.benchvm_os_caching
    storage_account_type          = var.benchvm_disk_storage_account_type
    disk_size_gb                  = var.benchvm_disk_size
  }

  source_image_reference {
    publisher                     = var.benchvm_image_publisher
    offer                         = var.benchvm_image_offer
    sku                           = var.benchvm_image_sku
    version                       = var.benchvm_image_version
  }
  tags = {
    Terraform                     = "True"
    PartOfInfra                   = "True"
    "Module"                      = "VM"
    "CreatedBy"                   = "Vector-Benchmarking-IaC"
  }
}
