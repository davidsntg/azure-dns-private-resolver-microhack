
########################################################################
# Azure Private DNS Zone - contoso.internal linked to onpremise-vnet
########################################################################

resource "azurerm_private_dns_zone" "contoso_internal" {
  name                = "contoso.internal"
  resource_group_name = azurerm_resource_group.onpremise-rg.name
}


resource "azurerm_private_dns_a_record" "onpremise_vm_contoso_internal" {
  name                = "onpremise-vm"
  zone_name           = azurerm_private_dns_zone.contoso_internal.name
  resource_group_name = azurerm_resource_group.onpremise-rg.name
  ttl                 = 300
  records             = ["10.233.1.4"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "contoso_onpremise" {
  name                  = "link"
  resource_group_name   = azurerm_resource_group.onpremise-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.contoso_internal.name
  virtual_network_id    = azurerm_virtual_network.onpremise-vnet.id
}


#####################################################################################
# Azure Private DNS Zone - contoso.azure linked to hub-vnet
#####################################################################################

resource "azurerm_private_dns_zone" "contoso_azure" {
  name                = "contoso.azure"
  resource_group_name = azurerm_resource_group.hub-rg.name
}

resource "azurerm_private_dns_a_record" "hub_vm_contoso_azure" {
  name                = "hub-vm"
  zone_name           = azurerm_private_dns_zone.contoso_azure.name
  resource_group_name = azurerm_resource_group.hub-rg.name
  ttl                 = 300
  records             = ["10.221.1.4"]
}

resource "azurerm_private_dns_a_record" "spoke01_vm_contoso_azure" {
  name                = "spoke01-vm"
  zone_name           = azurerm_private_dns_zone.contoso_azure.name
  resource_group_name = azurerm_resource_group.hub-rg.name
  ttl                 = 300
  records             = ["10.221.8.4"]
}

resource "azurerm_private_dns_zone_virtual_network_link" "contoso_azure" {
  name                  = "link"
  resource_group_name   = azurerm_resource_group.hub-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.contoso_azure.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id
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
