resource "azurerm_resource_group" "sc_rg" {
    name = "SC-RG"
    location = "Central US"
    tags = {
        environment = "sc-task"
    }
}

resource "azurerm_virtual_network" "sc_vnet" {
    name = "SC-Vnet"
    resource_group_name = azurerm_resource_group.sc_rg.name
    location = azurerm_resource_group.sc_rg.location
    address_space = ["10.0.0.0/16"]
    tags = {
        environment = "sc-task"
    }
}

resource "azurerm_subnet" "sc_subnet" {
    name = "AzureFirewallSubnet"
    resource_group_name = azurerm_resource_group.sc_rg.name
    virtual_network_name = azurerm_virtual_network.sc_vnet.name
    address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "sc_pub_ip" {
    name = "SC-Pub-IP"
    resource_group_name = azurerm_resource_group.sc_rg.name
    location = azurerm_resource_group.sc_rg.location
    allocation_method = "Static"
    tags = {
        environment = "sc-task"
    }
}

resource "azurerm_network_security_group" "sc_nsg" {
    name = "SC-NSG"
    resource_group_name = azurerm_resource_group.sc_rg.name
    location = azurerm_resource_group.sc_rg.location
    tags = {
        environment = "sc-task"
    }
}

resource "azurerm_network_security_rule" "sc_nsg_rule" {
    name = "SC-NSG-Rule"
    resource_group_name = azurerm_resource_group.sc_rg.name
    network_security_group_name = azurerm_network_security_group.sc_nsg.name
    priority = 150
    direction = "Outbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*"
    destination_address_prefix = "*"
}

resource "azurerm_network_interface" "sc_nic" {
    name = "SC-NIC"
    resource_group_name = azurerm_resource_group.sc_rg.name
    location = azurerm_resource_group.sc_rg.location

    ip_configuration {
        name = "SC-NIC-Config"
        subnet_id = azurerm_subnet.sc_subnet.id
        public_ip_address_id = azurerm_public_ip.sc_pub_ip.id
        private_ip_address_allocation = "Dynamic"
    }

    tags = {
        environment = "sc-task"
    }
}

resource "azurerm_firewall" "sc_fw" {
    name = "SC-FW"
    resource_group_name = azurerm_resource_group.sc_rg.name
    location = azurerm_resource_group.sc_rg.location

    ip_configuration {
        name = "SC-FW-Config"
        subnet_id = azurerm_subnet.sc_subnet.id
        public_ip_address_id = azurerm_public_ip.sc_pub_ip.id
    }

    tags = {
        environment = "sc-task"
    }
}

resource "azurerm_virtual_machine" "sc_vm" {
    name = "SC-VM"
    resource_group_name = azurerm_resource_group.sc_rg.name
    location = azurerm_resource_group.sc_rg.location
    network_interface_ids = [azurerm_network_interface.sc_nic.id]
    vm_size = "Standard_DS1_v2"

    storage_os_disk {
        name = "SC-OS-Disk"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "20.04-LTS"
        version = "Latest"
    }

    os_profile {
        computer_name = "Sc-vm"
        admin_username = "scvm"
        admin_password = "Scvm@12345"
    }
    
    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = {
        environment = "sc-task"
    }
}