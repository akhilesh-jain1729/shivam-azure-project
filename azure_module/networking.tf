resource "azurerm_virtual_network" "vpc" {
  name                = "my-vnet"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  address_space       = ["${var.azure_vpc_range}"]
  tags =  {
      Name = "vpc"
  }
  subnet {
  name                 = "subnet1-public"
  address_prefix       = var.azure_subnet1_range
  security_group       = azurerm_network_security_group.sg.id
  }

  subnet {
  name                 = "subnet2-private"
  address_prefix       = var.azure_subnet2_range
  security_group       = azurerm_network_security_group.sg.id
  }
}