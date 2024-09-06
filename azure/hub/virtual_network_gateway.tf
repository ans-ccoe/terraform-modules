##########################
# Virtual Network Gateway
##########################

resource "azurerm_public_ip" "virtual_network_gateway" {
  count = local.enable_virtual_network_gateway ? 1 : 0

  name                = var.virtual_network_gateway["public_ip_name"] == null ? format("pip-%s", var.virtual_network_gateway["name"]) : var.virtual_network_gateway["public_ip_name"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  sku               = "Standard"
  allocation_method = "Static"
  zones = length(regexall("AZ$", var.virtual_network_gateway["sku"])) == 0 ? null : ( // if the sku doesn't end in AZ then the zones are not used
    var.virtual_network_gateway["public_ip_zones"] != null ? (
      var.virtual_network_gateway["public_ip_zones"]) : (
      [for zone in data.azurerm_location.main.zone_mappings : zone.logical_zone]
    )
  )
}

resource "azurerm_route_table" "virtual_network_gateway" {
  count = local.use_virtual_network_gateway_route_table ? 1 : 0

  name                = var.virtual_network_gateway.route_table.name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = var.tags

  route = [for name, route in var.virtual_network_gateway.route_table.routes : {
    name                   = name
    address_prefix         = route.address_prefix
    next_hop_type          = route.next_hop_type
    next_hop_in_ip_address = route.next_hop_in_ip_address == "firewall" ? one(module.firewall[*].private_ip) : route.next_hop_in_ip_address
  }]
}

resource "azurerm_virtual_network_gateway" "main" {
  count = local.enable_virtual_network_gateway ? 1 : 0

  name                = var.virtual_network_gateway["name"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  generation = var.virtual_network_gateway["generation"]
  sku        = var.virtual_network_gateway["sku"]
  type       = var.virtual_network_gateway["type"]
  vpn_type   = var.virtual_network_gateway["vpn_type"]

  ip_configuration {
    name                 = "default"
    subnet_id            = local.virtual_network_gateway_subnet.id
    public_ip_address_id = azurerm_public_ip.virtual_network_gateway[count.index].id
  }
  timeouts {
    create = "1h"
    update = "1h"
    delete = "1h"
  }
}
