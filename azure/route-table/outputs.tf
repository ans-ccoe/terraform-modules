output "resource_group" {
  description = "The output of the resource group."
  value       = azurerm_route_table.main.resource_group_name
}

output "id" {
  description = "ID of the route table."
  value       = azurerm_route_table.main.id
}

output "route_table" {
  description = "The output of the route table resource."
  value       = azurerm_route_table.main
}

output "routes" {
  description = "The output of routes."
  value       = local.routes
}

output "subnets" {
  description = "The output of subnets that are associated with this Route Table."
  value       = azurerm_route_table.main.subnets

}

output "bgp_route_propagation_enabled" {
  description = "The output of whether BGP Route Propagation is enabled or not."
  value       = azurerm_route_table.main.disable_bgp_route_propagation
}