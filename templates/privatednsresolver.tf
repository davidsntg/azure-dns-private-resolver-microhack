# On-Prem DNS Private Resolver
resource "azurerm_private_dns_resolver" "onpremisednsresolver" {
  name                = "onpremisednsresolver"
  resource_group_name = azurerm_resource_group.onpremise-rg.name
  location            = azurerm_resource_group.onpremise-rg.location
  virtual_network_id  = azurerm_virtual_network.onpremise-vnet.id
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "dns-onpremise-inboundendpoint" {
  name                    = "dns-onpremise-inboundendpoint"
  private_dns_resolver_id = azurerm_private_dns_resolver.onpremisednsresolver.id
  location                = azurerm_private_dns_resolver.onpremisednsresolver.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.onpremise-dns-inbound-subnet.id
  }
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "dns-onpremise-outboundendpoint" {
  name                    = "dns-onpremise-outboundendpoint"
  private_dns_resolver_id = azurerm_private_dns_resolver.onpremisednsresolver.id
  location                = azurerm_private_dns_resolver.onpremisednsresolver.location
  subnet_id               = azurerm_subnet.onpremise-dns-outbound-subnet.id
}

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "onpremisednsruleset" {
  name                                       = "onpremisednsruleset"
  resource_group_name                        = azurerm_resource_group.onpremise-rg.name
  location                                   = azurerm_resource_group.onpremise-rg.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.dns-onpremise-outboundendpoint.id]
}

resource "azurerm_private_dns_resolver_virtual_network_link" "link_onpremisednsruleset_onpremisevnet" {
  name                      = "link_onpremisednsruleset_onpremisevnet"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.onpremisednsruleset.id
  virtual_network_id        = azurerm_virtual_network.onpremise-vnet.id
}

# Hub DNS Private Resolver
resource "azurerm_private_dns_resolver" "hubdnsresolver" {
  name                = "hubdnsresolver"
  resource_group_name = azurerm_resource_group.hub-rg.name
  location            = azurerm_resource_group.hub-rg.location
  virtual_network_id  = azurerm_virtual_network.hub-vnet.id
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "dns-hub-inboundendpoint" {
  name                    = "dns-hub-inboundendpoint"
  private_dns_resolver_id = azurerm_private_dns_resolver.hubdnsresolver.id
  location                = azurerm_private_dns_resolver.hubdnsresolver.location
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.hub-dns-inbound-subnet.id
  }
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "dns-hub-outboundendpoint" {
  name                    = "dns-hub-outboundendpoint"
  private_dns_resolver_id = azurerm_private_dns_resolver.hubdnsresolver.id
  location                = azurerm_private_dns_resolver.hubdnsresolver.location
  subnet_id               = azurerm_subnet.hub-dns-outbound-subnet.id
}

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "hubdnsruleset" {
  name                                       = "hubdnsruleset"
  resource_group_name                        = azurerm_resource_group.hub-rg.name
  location                                   = azurerm_resource_group.hub-rg.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.dns-hub-outboundendpoint.id]
}

resource "azurerm_private_dns_resolver_virtual_network_link" "link_hubdnsruleset_hubvnet" {
  name                      = "link_hubdnsruleset_hubvnet"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.hubdnsruleset.id
  virtual_network_id        = azurerm_virtual_network.hub-vnet.id
}
