####################
# Private DNS Zones
####################

resource "azurerm_private_dns_zone" "main" {
  for_each = var.private_dns_zones

  name                = each.key
  resource_group_name = each.value["resource_group_name"] != null ? each.value["resource_group_name"] : azurerm_resource_group.main.name
  tags                = var.tags
  dynamic "soa_record" {
    for_each = each.value.soa_record
    content {
      email        = soa_record.email
      expire_time  = soa_record.expire_time
      minimum_ttl  = soa_record.minimum_ttl
      refresh_time = soa_record.refresh_time
      retry_time   = soa_record.retry_time
      ttl          = soa_record.ttl
      tags         = soa_record.tags
    }
  }
}

#####################################
# Private Endpoint Private DNS Zones
#####################################

resource "azurerm_private_dns_zone" "pe_pdns" {
  for_each = local.private_endpoint_private_dns_zones

  name                = each.key
  resource_group_name = var.private_endpoint_private_dns_zone_resource_group_name != null ? var.private_endpoint_private_dns_zone_resource_group_name : azurerm_resource_group.main.name
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags["DateCreated"]]
  }
}