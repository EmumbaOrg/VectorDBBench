resource "azurerm_public_ip" "pgvm_public_ip" {
  count               = var.zone != null ? 1 : 0
  name                = "${var.name_prefix}_${var.dbvm_module_name_prefix}_public_ip"
  resource_group_name = var.resourcegroup_name
  location            = var.location
  sku                 = var.dbvm_ip_sku
  allocation_method   = var.dbvm_public_ip_allocation_method
  zones = var.zone ? [element(["1", "2", "3"], count.index + 1)] : []

  tags = {
    "Terraform"           = "True"
    "PartOfInfra"         = "True"
    "Module"              = "VM"
    "CreatedBy"           = "Vector-Benchmarking-IaC"
  }
}

resource "azurerm_network_interface" "pgvm-netinterface" {
  name                = "${var.name_prefix}_${var.dbvm_module_name_prefix}_nic"
  location            = var.location
  resource_group_name = var.resourcegroup_name

  ip_configuration {
    name                          = "vmipconfiguration"
    subnet_id                     = var.subnet_id[0]
    private_ip_address_allocation = var.dbvm_private_ip_allocation_method
    public_ip_address_id = azurerm_public_ip.pgvm_public_ip[0].id
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Store the Private Key Locally 
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/dbvm_key.pem"

  provisioner "local-exec" {
    command = "sudo chmod 600 ${path.module}/dbvm_key.pem"
  }
}

resource "azurerm_linux_virtual_machine" "pgvm" {
  name                = "${var.name_prefix}_${var.dbvm_module_name_prefix}"
  computer_name       = var.dbvm_module_name_prefix
  resource_group_name = var.resourcegroup_name
  location            = var.location
  size                = var.dbvm_vm_type
  admin_username      = var.dbvm_vm_username
  zone = var.zone
  network_interface_ids = [
    azurerm_network_interface.pgvm-netinterface.id,
  ]

  admin_ssh_key {
    username   = var.dbvm_vm_username
    public_key = tls_private_key.ssh_key.public_key_openssh  
  }

  custom_data = base64encode(file("${path.module}/pgvm-setup.sh"))

  os_disk {
    caching              = var.dbvm_vm_os_caching
    storage_account_type = var.dbvm_vm_disk_storage_account_type
    disk_size_gb = var.dbvm_vm_disk_size
  }

  source_image_reference {
    publisher = var.dbvm_vm_image_publisher
    offer     = var.dbvm_vm_image_offer
    sku       = var.dbvm_vm_image_sku
    version   = var.dbvm_vm_image_version
  }
  tags = {
    "Terraform"           = "True"
    "PartOfInfra"         = "True"
    "Module"              = "VM"
    "CreatedBy"           = "Vector-Benchmarking-IaC"
  }
}

resource "azurerm_managed_disk" "datadrive" {
  name                 = "${var.name_prefix}_${var.dbvm_module_name_prefix}_datadisk"
  location             = var.location
  resource_group_name  = var.resourcegroup_name
  storage_account_type = "PremiumV2_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1000"
  zone                 = var.zone
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadrive" {
  managed_disk_id    = azurerm_managed_disk.datadrive.id
  virtual_machine_id = azurerm_linux_virtual_machine.pgvm.id
  lun                = 10
  caching            = "None"
}