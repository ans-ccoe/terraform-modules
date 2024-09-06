#################
# Resource Group
#################

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

##########
# Hub VNet
##########

module "network" {
  source  = "ans-coe/virtual-network/azurerm"
  version = "1.3.0"

  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  address_space = var.address_space

  dns_servers       = var.dns_servers != "" ? var.dns_servers : []
  include_azure_dns = var.include_azure_dns

  ddos_protection_plan_id = var.ddos_protection_plan_id
  bgp_community           = var.bgp_community

  subnets = merge(
    local.enable_private_endpoint_subnet ? {
      (var.private_endpoint_subnet["subnet_name"]) = {
        prefix                                        = var.private_endpoint_subnet["address_prefix"]
        service_endpoints                             = var.private_endpoint_subnet["service_endpoints"]
        private_endpoint_network_policies_enabled     = false
        private_link_service_network_policies_enabled = false
      }
    } : {},

    # The firewall subnet is managed by the module found in firewall.tf
    #   count  = local.enable_firewall ? 1 : 0
    #   subnet_address_prefixes = [var.firewall["address_prefix"]

    local.enable_bastion ? {
      "AzureBastionSubnet" = {
        prefix = var.bastion["address_prefix"]
      }
    } : {},

    local.enable_virtual_network_gateway ? {
      "GatewaySubnet" = {
        prefix         = var.virtual_network_gateway["address_prefix"]
        associate_rt   = local.use_virtual_network_gateway_route_table ? true : null
        route_table_id = local.use_virtual_network_gateway_route_table ? one(azurerm_route_table.virtual_network_gateway[*].id) : null
      }
    } : {},

    local.enable_private_resolver ? {
      (var.private_resolver["inbound_subnet_name"]) = {
        prefix         = var.private_resolver["inbound_address_prefix"]
        associate_rt   = local.enable_firewall
        route_table_id = module.route_table.route_table.id
        delegations = {
          private-resolver = {
            service = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      },
      (var.private_resolver["outbound_subnet_name"]) = {
        prefix         = var.private_resolver["outbound_address_prefix"]
        associate_rt   = local.enable_firewall
        route_table_id = module.route_table.route_table.id
        delegations = {
          private-resolver = {
            service = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      },
    } : {},
    local.extra_subnets
  )

  private_dns_zones = {
    for k, zone in var.private_dns_zones
    : k => {
      resource_group_name  = zone.resource_group_name != null ? zone.resource_group_name : azurerm_resource_group.main.name
      registration_enabled = zone.registration_enabled
    }
  }
}