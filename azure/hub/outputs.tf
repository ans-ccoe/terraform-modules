##########
# Outputs
##########

output "resource_group_name" {
  description = "Output of the Resource Group name created by the Hub module"
  value       = azurerm_resource_group.main.name
}

output "network" {
  description = "Output from the network module."
  value       = module.network
}

output "id" {
  description = "Output from the network module."
  value       = module.network.id
}

output "firewall" {
  description = "Output from the firewall."
  value       = local.firewall
}

output "bastion" {
  description = "Output from the bastion module."
  value       = local.bastion
}

output "virtual_network_gateway" {
  description = "Output from the virtual network gateway."
  value       = local.virtual_network_gateway
}

output "private_resolver" {
  description = "Output from the private resolver."
  value       = local.private_resolver
}

output "private_resolver_inbound_endpoint" {
  description = "Output from the private resolver inbound endpoint."
  value       = local.private_resolver_inbound_endpoint
}

output "private_resolver_outbound_endpoint" {
  description = "Output from the private resolver outbound endpoint."
  value       = local.private_resolver_outbound_endpoint
}

output "network_watcher" {
  description = "Output of the network watcher."
  value       = one(azurerm_network_watcher.main[*])
}

output "extra_subnets_route_table" {
  description = "Details about the Route Table created for extra subnets."
  value       = local.extra_subnets_route_table
}

output "extra_subnets_network_security_group" {
  description = "Details about the NSG created for extra subnets."
  value = local.extra_subnets_network_security_group
}