/*

The following links provide the documentation for the new blocks used
in this terraform configuration file

1. azurerm_windows_virtual_machine_scale_set - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine_scale_set

*/

resource "azurerm_windows_virtual_machine_scale_set" "appset" {  
  name                = "appset"
  resource_group_name = local.resource_group_name
  location            = local.location 
  sku                = "Standard_D2s_v3"
  instances = 2
  admin_username      = "adminuser"
  admin_password      = "Azure@123"  
  upgrade_mode = "Automatic"
    
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  network_interface {
    name="scaleset-interface"
    primary=true

    ip_configuration {
    name="internal"
    primary=true
    subnet_id=azurerm_subnet.subnetA.id
    load_balancer_backend_address_pool_ids=[azurerm_lb_backend_address_pool.scalesetpool.id]
  }
  }
 
   depends_on = [
    azurerm_subnet.subnetA,    
    azurerm_resource_group.appgrp,
    azurerm_lb_backend_address_pool.scalesetpool
  ]
}

# --------------------- metricas
resource "azurerm_monitor_autoscale_setting" "monitorscale" {
  name                = "monitorscale"
  resource_group_name = local.resource_group_name
  location            = local.location
  target_resource_id  = azurerm_windows_virtual_machine_scale_set.appset.id
  profile {
    name = "defaultProfile"
    capacity {
      default = 2
      minimum = 1
      maximum = 4
    }
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.appset.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
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
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.appset.id
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
}

