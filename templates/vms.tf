

# Generate random string for storage
resource "random_string" "asa" {
  length  = 4
  special = "false"
  upper   = "false"
}

#########################################################
# On-premise VM
#########################################################

resource "azurerm_storage_account" "onpremise-sa" {
  name                     = "onpremisesa${random_string.asa.result}"
  location                 = azurerm_resource_group.onpremise-rg.location
  resource_group_name      = azurerm_resource_group.onpremise-rg.name
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

resource "azurerm_network_interface" "onpremise-vm-nic" {
  name                = "onpremise-vm-ni01"
  location            = azurerm_resource_group.onpremise-rg.location
  resource_group_name = azurerm_resource_group.onpremise-rg.name

  ip_configuration {
    name                          = "ipConfig1"
    subnet_id                     = azurerm_subnet.onpremise-default-subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "onpremise"
    deployment  = "terraform"
    microhack   = "dns-private-resolver"
  }
}

resource "azurerm_linux_virtual_machine" "onpremise-vm" {
  name                            = "onpremise-vm"
  resource_group_name             = azurerm_resource_group.onpremise-rg.name
  location                        = azurerm_resource_group.onpremise-rg.location
  size                            = var.vm_size
  admin_username                  = "adminuser"
  disable_password_authentication = "false"
  admin_password                  = var.admin_password
  network_interface_ids           = [azurerm_network_interface.onpremise-vm-nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "onpremise-vm-od01"
  }

  source_image_reference {
    publisher = var.vm_os_publisher
    offer     = var.vm_os_offer
    sku       = var.vm_os_sku
    version   = var.vm_os_version
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.onpremise-sa.primary_blob_endpoint
  }

  tags = {
    environment = "onprem"
    deployment  = "terraform"
    microhack   = "dns-private-resolver"
  }
}

#########################################################
# Azure hub VM
#########################################################

resource "azurerm_storage_account" "hub-sa" {
  name                     = "hubsa${random_string.asa.result}"
  location                 = azurerm_resource_group.hub-rg.location
  resource_group_name      = azurerm_resource_group.hub-rg.name
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

resource "azurerm_network_interface" "hub-vm-nic" {
  name                = "hub-vm-ni01"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name

  ip_configuration {
    name                          = "ipConfig1"
    subnet_id                     = azurerm_subnet.hub-default-subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "onprem"
    deployment  = "terraform"
    microhack   = "dns-private-resolver"
  }
}

resource "azurerm_linux_virtual_machine" "hub-vm" {
  name                            = "hub-vm"
  resource_group_name             = azurerm_resource_group.hub-rg.name
  location                        = azurerm_resource_group.hub-rg.location
  size                            = var.vm_size
  admin_username                  = "adminuser"
  disable_password_authentication = "false"
  admin_password                  = var.admin_password
  network_interface_ids           = [azurerm_network_interface.hub-vm-nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "hub-vm-od01"
  }

  source_image_reference {
    publisher = var.vm_os_publisher
    offer     = var.vm_os_offer
    sku       = var.vm_os_sku
    version   = var.vm_os_version
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.hub-sa.primary_blob_endpoint
  }

  tags = {
    environment = "cloud"
    deployment  = "terraform"
    microhack   = "dns-private-resolver"
  }
}

#########################################################
# Azure spoke01 VM
#########################################################

resource "azurerm_storage_account" "spoke01-sa" {
  name                     = "spoke01sa${random_string.asa.result}"
  location                 = azurerm_resource_group.spoke01-rg.location
  resource_group_name      = azurerm_resource_group.spoke01-rg.name
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

resource "azurerm_network_interface" "spoke01-vm-nic" {
  name                = "spoke01-vm-ni01"
  location            = azurerm_resource_group.spoke01-rg.location
  resource_group_name = azurerm_resource_group.spoke01-rg.name

  ip_configuration {
    name                          = "ipConfig1"
    subnet_id                     = azurerm_subnet.spoke01-default-subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "cloud"
    deployment  = "terraform"
    microhack   = "dns-private-resolver"
  }
}

resource "azurerm_linux_virtual_machine" "spoke01-vm" {
  name                            = "spoke01-vm"
  resource_group_name             = azurerm_resource_group.spoke01-rg.name
  location                        = azurerm_resource_group.spoke01-rg.location
  size                            = var.vm_size
  admin_username                  = "adminuser"
  disable_password_authentication = "false"
  admin_password                  = var.admin_password
  network_interface_ids           = [azurerm_network_interface.spoke01-vm-nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "spoke01-vm-od01"
  }

  source_image_reference {
    publisher = var.vm_os_publisher
    offer     = var.vm_os_offer
    sku       = var.vm_os_sku
    version   = var.vm_os_version
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.spoke01-sa.primary_blob_endpoint
  }

  tags = {
    environment = "cloud"
    deployment  = "terraform"
    microhack   = "dns-private-resolver"
  }
}
