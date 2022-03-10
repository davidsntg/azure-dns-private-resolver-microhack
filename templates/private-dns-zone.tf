
########################################################################
# Azure Private DNS Zone - contoso.internal linked to onpremise-vnet
########################################################################

resource "azurerm_private_dns_zone" "contoso_internal" {
  name                = "contoso.internal"
  resource_group_name = azurerm_resource_group.onpremise-rg.name
}


resource "azurerm_private_dns_a_record" "johndoe_contoso_internal" {
  name                = "johndoe"
  zone_name           = azurerm_private_dns_zone.contoso_internal.name
  resource_group_name = azurerm_resource_group.onpremise-rg.name
  ttl                 = 300
  records             = ["1.2.3.4"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "contoso_onpremise" {
  name                  = "link"
  resource_group_name   = azurerm_resource_group.onpremise-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.contoso_internal.name
  virtual_network_id    = azurerm_virtual_network.onpremise-vnet.id
}


#####################################################################################
# Azure Private DNS Zone - privatelink.postgres.database.azure.com linked to hub-vnet
#####################################################################################

resource "azurerm_private_dns_zone" "privatelink_postgres_database_azure_com" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.hub-rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_postgres_hub" {
  name                  = "link"
  resource_group_name   = azurerm_resource_group.hub-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_postgres_database_azure_com.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id
}