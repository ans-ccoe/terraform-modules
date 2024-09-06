locals {
  zones = [for zone in data.azurerm_location.main.zone_mappings : zone.logical_zone]
}