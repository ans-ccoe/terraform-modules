##############
# Route Table
##############

resource "azurerm_route_table" "main" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  disable_bgp_route_propagation = var.disable_bgp_route_propagation
}

#########
# Routes
#########

resource "azurerm_route" "main" {
  for_each = var.routes

  name                = each.key
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.main.name

  address_prefix         = each.value["address_prefix"]
  next_hop_type          = each.value["next_hop_type"]
  next_hop_in_ip_address = each.value["next_hop_in_ip_address"]
}

resource "azurerm_route" "default" {
  count = var.default_route != null ? 1 : 0

  name                = var.default_route.name
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.main.name

  address_prefix         = "0.0.0.0/0"
  next_hop_type          = var.default_route.next_hop_type
  next_hop_in_ip_address = var.default_route.next_hop_in_ip_address
}

##########################
# Route Table Association
##########################

resource "azurerm_subnet_route_table_association" "main" {
  count = length(var.subnet_ids)

  subnet_id      = var.subnet_ids[count.index]
  route_table_id = azurerm_route_table.main.id
}