#############
# Network
#############

resource "azurerm_public_ip" "main" {
  name                = var.pip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
  zones             = var.zone_redundant ? local.zones : []
}

resource "azurerm_subnet" "main" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.subnet_address_prefixes
}

#############
# Firewall
#############

resource "azurerm_firewall" "main" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.firewall_sku_name
  sku_tier            = var.firewall_sku_tier
  dns_servers         = var.firewall_dns_servers
  private_ip_ranges   = var.private_ip_ranges
  tags                = var.tags
  firewall_policy_id  = var.firewall_policy_id
  zones               = var.zone_redundant ? local.zones : []

  ip_configuration {
    name                 = "ip_configuration"
    subnet_id            = azurerm_subnet.main.id
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

module "route-table" {
  source = "../route-table"
  count  = var.route_table_name != null ? 1 : 0

  name                = var.route_table_name != null ? var.route_table_name : "rt-${azurerm_firewall.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  subnet_ids = [azurerm_subnet.main.id]

  default_route = {
    name          = var.default_route_name
    next_hop_type = "Internet"
  }

  routes = var.extra_routes
}