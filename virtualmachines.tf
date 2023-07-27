resource "azurerm_network_interface" "appinterface" {
  count=var.number_of_machines
  name                = "appinterface${count.index}"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets[count.index].id
    private_ip_address_allocation = "Dynamic"    
  }
  depends_on = [
    azurerm_subnet.subnets
  ]
}

resource "azurerm_windows_virtual_machine" "appvm" {
  count=var.number_of_machines
  name                = "appvm${count.index}"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_D2S_v3"
  admin_username      = "adminuser"
  admin_password      = "Larissa@251210"
  zone=(count.index+1)
  network_interface_ids = [
    azurerm_network_interface.appinterface[count.index].id,
  ]

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
  depends_on = [
    azurerm_network_interface.appinterface,
    azurerm_resource_group.appgrp
  ]
}