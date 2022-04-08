# Request subscription id

$subscriptionId = Read-Host "Subscription Id"

$path = Get-Location

New-Item -path $path -Name "PSRepo" -ItemType "directory"
Invoke-WebRequest -Uri "https://github.com/sfiguemsft/privateresolver/blob/main/Az.DnsResolver.0.1.4.zip" -OutFile "$path/PSRepo/Az.DnsResolver.0.1.4.zip"

Register-PSRepository -Name LocalPSRepo -SourceLocation "$path/PSRepo" -ScriptSourceLocation "$path/PSRepo" -InstallationPolicy Trusted

# Setup local Powershell repository and install Az.DnsResolver Powershell module

Install-Module Az.DnsResolver

Update-Module -Name Az.DnsResolver

Get-InstalledModule -Name Az.DnsResolver

# Set subscription context in Azure Powershell
Connect-AzAccount -Environment AzureCloud

Select-AzSubscription -SubscriptionObject (Get-AzSubscription -SubscriptionId $subscriptionId)

Register-AzResourceProvider -ProviderNamespace Microsoft.Network

# Azure hub - Create the DNS resolver instance
New-AzDnsResolver -Name hubdnsresolver -ResourceGroupName hub-rg -Location eastus2 -VirtualNetworkId "/subscriptions/$subscriptionId/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet"

$HubIpConfigOne = New-AzDnsResolverIPConfigurationObject -PrivateIPAllocationMethod Dynamic -SubnetId "/subscriptions/$subscriptionId/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet/subnets/snet-dns-inbound"
New-AzDnsResolverInboundEndpoint -Name dns-hub-inboundendpoint -DnsResolverName hubdnsresolver -ResourceGroupName hub-rg -IPConfiguration $HubIpConfigOne -Location eastus2
New-AzDnsResolverOutboundEndpoint -DnsResolverName hubdnsresolver -Name dns-hub-outboundendpoint -ResourceGroupName hub-rg -SubnetId "/subscriptions/$subscriptionId/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet/subnets/snet-dns-outbound" -Location eastus2
$hubOutboundEndpoint = Get-AzDnsResolverOutboundEndpoint -Name dns-hub-outboundendpoint -DnsResolverName hubdnsresolver -ResourceGroupName hub-rg

# Azure hub - Create the DNS forwarding ruleset
New-AzDnsForwardingRuleset -Name hubdnsruleset -ResourceGroupName hub-rg -DnsResolverOutboundEndpoint $hubOutboundEndpoint -Location eastus2
$hubDnsForwardingRuleset = Get-AzDnsForwardingRuleset -Name hubdnsruleset -ResourceGroupName hub-rg

# Azure hub - Link hub Forwarding ruleset to hub-vnet
$hubVnet = Get-AzVirtualNetwork -Name hub-vnet -ResourceGroupName hub-rg
New-AzDnsForwardingRulesetVirtualNetworkLink -DnsForwardingRulesetName $hubDnsForwardingRuleset.Name -ResourceGroupName hub-rg -VirtualNetworkLinkName "vnetlink" -VirtualNetworkId $hubVnet.Id -SubscriptionId "$subscriptionId"

# Azure spoke - Create the DNS forwarding ruleset (not used before challenge 3)
New-AzDnsForwardingRuleset -Name spokednsruleset -ResourceGroupName spoke01-rg -DnsResolverOutboundEndpoint $hubOutboundEndpoint -Location eastus2

# On-premise - Create the DNS resolver instance
New-AzDnsResolver -Name onpremisednsresolver -ResourceGroupName onpremise-rg -Location westcentralus -VirtualNetworkId "/subscriptions/$subscriptionId/resourceGroups/onpremise-rg/providers/Microsoft.Network/virtualNetworks/onpremise-vnet"

$OnpremiseIpConfigOne = New-AzDnsResolverIPConfigurationObject -PrivateIPAllocationMethod Dynamic -SubnetId "/subscriptions/$subscriptionId/resourceGroups/onpremise-rg/providers/Microsoft.Network/virtualNetworks/onpremise-vnet/subnets/snet-dns-inbound"
New-AzDnsResolverInboundEndpoint -Name dns-onpremise-inboundendpoint -DnsResolverName onpremisednsresolver -ResourceGroupName onpremise-rg -IPConfiguration $OnpremiseIpConfigOne -Location westcentralus
New-AzDnsResolverOutboundEndpoint -DnsResolverName onpremisednsresolver -Name dns-onpremise-outboundendpoint -ResourceGroupName onpremise-rg -SubnetId "/subscriptions/$subscriptionId/resourceGroups/onpremise-rg/providers/Microsoft.Network/virtualNetworks/onpremise-vnet/subnets/snet-dns-outbound" -Location westcentralus
$OnpremiseOutboundEndpoint = Get-AzDnsResolverOutboundEndpoint -Name dns-onpremise-outboundendpoint -DnsResolverName onpremisednsresolver -ResourceGroupName onpremise-rg

# On-premise - Create the DNS forwarding ruleset
New-AzDnsForwardingRuleset -Name onpremisednsruleset -ResourceGroupName onpremise-rg -DnsResolverOutboundEndpoint $OnpremiseOutboundEndpoint -Location westcentralus
$OnpremiseDnsForwardingRuleset = Get-AzDnsForwardingRuleset -Name onpremisednsruleset -ResourceGroupName onpremise-rg

# On-premise - Link onpremise Forwarding ruleset to onpremise-vnet
$OnpremiseVnet = Get-AzVirtualNetwork -Name onpremise-vnet -ResourceGroupName onpremise-rg
New-AzDnsForwardingRulesetVirtualNetworkLink -DnsForwardingRulesetName $OnpremiseDnsForwardingRuleset.Name -ResourceGroupName onpremise-rg -VirtualNetworkLinkName "vnetlink" -VirtualNetworkId $OnpremiseVnet.Id -SubscriptionId "$subscriptionId"
