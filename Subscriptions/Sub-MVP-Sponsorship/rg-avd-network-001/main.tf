resource "azurerm_resource_group" "resourcegroup" {
    name        = var.ResourceGroup
    location    = var.Location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.vNetName
  address_space       = var.vnet.address_space
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name 
}
resource "azurerm_subnet" "subnets" {
  for_each = var.Subnets
  name                 = each.value["name"]
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value["prefix"]
  
  depends_on = [
    azurerm_virtual_network.vnet
  ] 
}

resource "azurerm_network_security_group" "networksecuritygroups" {
  for_each = var.Subnets
  name                = "nsg-${each.value["name"]}"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name  
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = var.Subnets
  subnet_id                 = azurerm_subnet.subnets[each.value["name"]].id
  network_security_group_id = azurerm_network_security_group.networksecuritygroups[each.value["name"]].id 
}