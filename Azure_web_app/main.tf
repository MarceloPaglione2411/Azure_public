resource "azurerm_resource_group" "appgrp" {
  name     = local.resource_group_name
  location = local.location  
}

resource "random_uuid" "serviceplanidentifier" {

}

output "randomid"{
      value=substr(random_uuid.serviceplanidentifier.result,0,8)
}

resource "random_uuid" "windowswebappidentifier" {

}

output "randomid2"{
      value=substr(random_uuid.windowswebappidentifier.result,0,8)
}