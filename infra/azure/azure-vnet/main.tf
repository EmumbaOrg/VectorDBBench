
resource "azurerm_virtual_network" "pgbench-vnet" {
  name                = "${var.name_prefix}-vnet"
  location            = var.location
  resource_group_name = var.resourcegroup_name
  address_space       = var.vnet_ipaddress 
  tags = {
    Terraform           = "True"
    PartOfInfra         = "True"
    "Module"            = "VNET"
    "CreatedBy"         = "Vector-Benchmarking-IaC"
  }
  subnet {
    name                = "${var.vnet_module_name_prefix}-subnet"
    address_prefix      = var.vnet_subnet_address[0] 
    security_group      = azurerm_network_security_group.pgbench-sg.id
  }
}

resource "azurerm_network_security_group" "pgbench-sg" {
  name                = "${var.name_prefix}-nsg"
  location            = var.location
  resource_group_name = var.resourcegroup_name

  security_rule {
    name                       = "${var.name_prefix}-vnetrule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
}