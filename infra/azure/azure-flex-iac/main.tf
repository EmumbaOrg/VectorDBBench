
resource "azurerm_postgresql_flexible_server" "pg_flex_server" {
  name                   = "${var.name_prefix}-${var.flex_module_name_prefix}-db" 
  resource_group_name    = var.resourcegroup_name
  location               = var.location
  version                = var.flex_pgversion
  public_network_access_enabled = var.flex_publicaccess
  administrator_login    = var.flex_dbuser
  administrator_password = var.flex_dbpassword
  zone                   = var.zone
  storage_mb             = var.flex_server_storage
  sku_name               = var.flex_server_sku
  auto_grow_enabled      = false
  #backup_retention_days  = 7

  tags = {
    "Terraform"           = "True"
    "PartOfInfra"         = "True"
    "Module"            = "FLEXIBLE SERVER"
    "CreatedBy"         = "Vector-Benchmarking-IaC"
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "dbaccess" {
  depends_on = [ azurerm_postgresql_flexible_server.pg_flex_server ]
  name                = "flexdbaccessrule"
  server_id           = azurerm_postgresql_flexible_server.pg_flex_server.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

resource "azurerm_postgresql_flexible_server_configuration" "parameter_config" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.pg_flex_server.id
  value     = "VECTOR"
}