##################
# Network Watcher
##################

# Conditions for resource group:
# If network_watcher_resource_group is specified = create network watcher RG
# If network_watcher_resource_group is unspecified = spoke resource group

resource "azurerm_resource_group" "network_watcher" {
  count = local.create_network_watcher_resource_group ? 1 : 0

  name     = var.network_watcher_resource_group_name != null ? var.network_watcher_resource_group_name : "NetworkWatcherRG"
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_watcher" "main" {
  count = var.enable_network_watcher ? 1 : 0

  name                = local.network_watcher_name
  location            = var.location
  resource_group_name = local.network_watcher_resource_group_name
  tags                = var.tags
}