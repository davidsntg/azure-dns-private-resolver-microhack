
resource "random_string" "random" {
  length = 6
  special = false
  upper = false
}

resource "azurerm_postgresql_server" "spoke01-pgsql" {
  name                = "spoke01-${random_string.random.result}-pgsql"
  location            = azurerm_resource_group.spoke01-rg.location
  resource_group_name = azurerm_resource_group.spoke01-rg.name

  sku_name = "GP_Gen5_2"

  
  storage_mb                   = 51200
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true
  

  administrator_login              = "adminuser"
  administrator_login_password     = var.admin_password
  version                          = "11"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "azurerm_private_endpoint" "spoke01-pgsql-pe" {
  name                = "spoke01-${random_string.random.result}-pgsql-endpoint"
  location            = azurerm_resource_group.spoke01-rg.location
  resource_group_name = azurerm_resource_group.spoke01-rg.name
  subnet_id           = azurerm_subnet.spoke01-default-subnet.id

  private_service_connection {
    name                           = "spoke01-${random_string.random.result}-pgsql-privateserviceconnection"
    private_connection_resource_id = azurerm_postgresql_server.spoke01-pgsql.id
    subresource_names              = [ "postgresqlServer" ]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-postgres"
    private_dns_zone_ids = [azurerm_private_dns_zone.privatelink_postgres_database_azure_com.id]
  }
}