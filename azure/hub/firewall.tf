###########
# Firewall
###########

module "firewall" {
  count  = local.enable_firewall ? 1 : 0
  source = "../firewall"

  firewall_name       = var.firewall["name"]
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = var.tags

  virtual_network_name    = module.network.name
  pip_name                = var.firewall["public_ip_name"] == null ? format("pip-%s", var.firewall["name"]) : var.firewall["public_ip_name"]
  subnet_address_prefixes = [var.firewall["address_prefix"]]

  route_table_name = var.firewall["route_table_name"] != null ? var.firewall["route_table_name"] : "rt-azfw-${module.network.name}"

  firewall_sku_name  = "AZFW_VNet"
  firewall_sku_tier  = var.firewall["sku_tier"]
  zone_redundant     = var.firewall["zone_redundant"]
  firewall_policy_id = var.firewall["firewall_policy_id"]
}