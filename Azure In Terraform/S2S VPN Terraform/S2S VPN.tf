resource "azurerm_resource_group" "Sarath-S2S" {
  name     = "S2S-RG"
  location = "East US"
}

resource "azurerm_virtual_network" "Sarath-S2S" {
  name                = "S2S-Vnet"
  location            = azurerm_resource_group.Sarath-S2S.location
  resource_group_name = azurerm_resource_group.Sarath-S2S.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "Sarath-S2S" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.Sarath-S2S.name
  virtual_network_name = azurerm_virtual_network.Sarath-S2S.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_local_network_gateway" "onpremise" {
  name                = "onpremise"
  location            = azurerm_resource_group.Sarath-S2S.location
  resource_group_name = azurerm_resource_group.Sarath-S2S.name
  gateway_address     = "168.62.225.23"
  address_space       = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "Sarath-S2S" {
  name                = "S2S-PublicIP"
  location            = azurerm_resource_group.Sarath-S2S.location
  resource_group_name = azurerm_resource_group.Sarath-S2S.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "Sarath-S2S" {
  name                = "S2S-VNG"
  location            = azurerm_resource_group.Sarath-S2S.location
  resource_group_name = azurerm_resource_group.Sarath-S2S.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.Sarath-S2S.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.Sarath-S2S.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "onpremise" {
  name                = "onpremise"
  location            = azurerm_resource_group.Sarath-S2S.location
  resource_group_name = azurerm_resource_group.Sarath-S2S.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.Sarath-S2S.id
  local_network_gateway_id   = azurerm_local_network_gateway.onpremise.id

  shared_key = "4-v3ry-53cr37-1p53c-5h4r3d-k3y"
}