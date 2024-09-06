###################
# Private Resolver
###################

resource "azurerm_private_dns_resolver" "main" {
  count = local.enable_private_resolver ? 1 : 0

  name                = var.private_resolver["name"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  virtual_network_id = module.network.id
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "main" {
  count = local.enable_private_resolver ? 1 : 0

  name                    = var.private_resolver["inbound_endpoint_name"] == null ? format("%s-in", var.private_resolver["name"]) : var.private_resolver["inbound_endpoint_name"]
  location                = var.location
  private_dns_resolver_id = azurerm_private_dns_resolver.main[0].id
  tags                    = var.tags

  ip_configurations {
    subnet_id = local.private_resolver_inbound_subnet.id
  }
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "main" {
  count = local.enable_private_resolver ? 1 : 0

  name                    = var.private_resolver["outbound_endpoint_name"] == null ? format("%s-out", var.private_resolver["name"]) : var.private_resolver["outbound_endpoint_name"]
  location                = var.location
  private_dns_resolver_id = azurerm_private_dns_resolver.main[0].id
  tags                    = var.tags

  subnet_id = local.private_resolver_outbound_subnet.id
}
