resource "azurerm_resource_group" "Sarath-fw" {
  name     = "RG-FW-TF"
  location = "East US"
}

resource "azurerm_virtual_network" "Sarath-fw" {
  name                = "fw-vnet"
  address_space    = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Sarath-fw.location
  resource_group_name = azurerm_resource_group.Sarath-fw.name
}

resource "azurerm_subnet" "Sarath-fw" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.Sarath-fw.name
  virtual_network_name = azurerm_virtual_network.Sarath-fw.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "Sarath-fw" {
  name                = "fw-public-ip"
  location            = azurerm_resource_group.Sarath-fw.location
  resource_group_name = azurerm_resource_group.Sarath-fw.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "Sarath-fw" {
  name                = "tf-firewall"
  location            = azurerm_resource_group.Sarath-fw.location
  resource_group_name = azurerm_resource_group.Sarath-fw.name

  ip_configuration {
    name                 = "ip-config"
    subnet_id            = azurerm_subnet.Sarath-fw.id
    public_ip_address_id = azurerm_public_ip.Sarath-fw.id
  }
}