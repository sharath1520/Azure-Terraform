resource "azurerm_resource_group" "Sarath-NSG" {
  name     = "ResourceGroup-NSG"
  location = "Central US"
}

resource "azurerm_network_security_group" "Sarath-NSG" {
  name                = "NSG-TEST"
  location            = azurerm_resource_group.Sarath-NSG.location
  resource_group_name = azurerm_resource_group.Sarath-NSG.name
}

resource "azurerm_network_security_rule" "Sarath-NSG" {
  name                        = "NSG-TEST-RULe"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.Sarath-NSG.name
  network_security_group_name = azurerm_network_security_group.Sarath-NSG.name
}