terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "SARATHRG" {
    name     = "SARATHRGroup"
    location = "eastus"
    tags = {
        environment = "Terraform Test"
    }
}


# Create virtual network
resource "azurerm_virtual_network" "SARATHVN" {
    name                = "SARATHVNET"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.SARATHRG.name
    tags = {
        environment = "Terraform Test"
    }
}







# Create subnet
resource "azurerm_subnet" "azFSubnet" {
    name                 = "SARATHRGRGSubnet"
    resource_group_name  = azurerm_resource_group.SARATHRG.name
    virtual_network_name = azurerm_virtual_network.SARATHVN.name
    address_prefixes     = ["10.0.1.0/24"]
}


# Create public IPs
resource "azurerm_public_ip" "azpublicip" {
    name                         = "SARATHRGPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.SARATHRG.name
    allocation_method            = "Dynamic"
    tags = {
        environment = "Terraform Test"
    }
}



# Create Network Security Group and rule
resource "azurerm_network_security_group" "SARATHNetSec" {
    name                = "myNetworkSecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.SARATHRG.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "10.0.1.0/24"
        destination_address_prefix = "*"
    }
    tags = {
        environment = "Terraform Test"
    }
}