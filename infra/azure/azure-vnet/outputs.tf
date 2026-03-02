output "vnet_subnet_id" {
  value = azurerm_virtual_network.pgbench-vnet.subnet[*].id
}