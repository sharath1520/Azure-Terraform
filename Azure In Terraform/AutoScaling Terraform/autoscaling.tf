resource "azurerm_resource_group" "AS-TEST-RG" {
  name     = "AutoScalingTest-TF"
  location = "East US"
}

resource "azurerm_virtual_network" "AS-TEST-RG" {
  name                = "AutoScaling-network"
  resource_group_name = azurerm_resource_group.AS-TEST-RG.name
  location            = azurerm_resource_group.AS-TEST-RG.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.AS-TEST-RG.name
  virtual_network_name = azurerm_virtual_network.AS-TEST-RG.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_windows_virtual_machine_scale_set" "AS-TEST-RG" {
  name                = "AS-vmss"
  resource_group_name = azurerm_resource_group.AS-TEST-RG.name
  location            = azurerm_resource_group.AS-TEST-RG.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_password      = "Autoscaling1234"
  admin_username      = "autoscaling"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "AutoScaling-RG"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }
}
resource "azurerm_monitor_autoscale_setting" "AS-TEST-RG" {
  name                = "myAutoscaleSetting"
  resource_group_name = azurerm_resource_group.AS-TEST-RG.name
  location            = azurerm_resource_group.AS-TEST-RG.location
  target_resource_id  = azurerm_windows_virtual_machine_scale_set.AS-TEST-RG.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.AS-TEST-RG.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        dimensions {
          name     = "AppName"
          operator = "Equals"
          values   = ["App1"]
        }
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.AS-TEST-RG.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = ["sarathdevarakonda1520@outlook.com"]
    }
  }
}