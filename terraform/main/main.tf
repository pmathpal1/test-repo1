resource "azurerm_virtual_network" "vnet" {
  count               = length(var.vnet)
  name                = var.vnet[count.index].name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet[count.index].address_space]

}

resource "azurerm_subnet" "subnets" {
  count                = length(var.subnet)
  name                 = var.subnet[count.index].subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = var.subnet[count.index].name
  address_prefixes     = [var.subnet[count.index].address_prefix]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

output "subnet_id" {
  value = azurerm_subnet.subnets.*.id
}