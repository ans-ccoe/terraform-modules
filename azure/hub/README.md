# Terraform (Module) - Azurerm - Hub

#### Table of Contents

- [Terraform (Module) - Azurerm - Hub](#terraform-module---azurerm---hub)
      - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
    - [Network Watcher](#network-watcher)
  - [Requirements](#requirements)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Resources](#resources)
  - [Modules](#modules)

## Usage

This module deploys a predefined hub network with the option to include focused features - Firewall, Bastion, Virtual Network Gateway & Private DNS Resolver.

This module creates a single resource group for all hub related resources.  

If a resource group name for Bastion is specified, a resource group will be created.  If no name is entered, the main hub resource group will be used.

### Network Watcher
In order to manage network watcher via Terraform, the automatic creation of Network Watcher in Azure needs to be disabled in the subscription. Otherwise Terraform will error out.

az account set -s "SUBSCRIPTION NAME"

az feature register --name DisableNetworkWatcherAutocreation --namespace Microsoft.Network

az provider register -n Microsoft.Network


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.101 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | Address range for the virtual network. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location to deploy to. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group created for the hub. | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the virtual network. | `string` | n/a | yes |
| <a name="input_bastion"></a> [bastion](#input\_bastion) | Configuration for the bastion if enabled. | <pre>object({<br>    name                        = string<br>    create_resource_group       = optional(bool, true)<br>    resource_group_name         = optional(string)<br>    address_prefix              = string<br>    public_ip_name              = optional(string)<br>    network_security_group_name = optional(string)<br>    whitelist_cidrs             = optional(list(string), ["Internet"])<br>  })</pre> | `null` | no |
| <a name="input_bgp_community"></a> [bgp\_community](#input\_bgp\_community) | The BGP Community for this virtual network. | `string` | `null` | no |
| <a name="input_create_extra_subnets_default_route"></a> [create\_extra\_subnets\_default\_route](#input\_create\_extra\_subnets\_default\_route) | Create default route in the firewall | `bool` | `true` | no |
| <a name="input_create_extra_subnets_network_security_group"></a> [create\_extra\_subnets\_network\_security\_group](#input\_create\_extra\_subnets\_network\_security\_group) | Create a Network Security Group to associate with all user defined subnets. | `bool` | `false` | no |
| <a name="input_create_network_watcher_resource_group"></a> [create\_network\_watcher\_resource\_group](#input\_create\_network\_watcher\_resource\_group) | Do we want to create a network watcher resource group | `bool` | `true` | no |
| <a name="input_create_private_endpoint_private_dns_zones"></a> [create\_private\_endpoint\_private\_dns\_zones](#input\_create\_private\_endpoint\_private\_dns\_zones) | Add the list of private endpoint private dns zones to the list of private dns zones to create. | `bool` | `false` | no |
| <a name="input_ddos_protection_plan_id"></a> [ddos\_protection\_plan\_id](#input\_ddos\_protection\_plan\_id) | A DDoS Protection plan ID to assign to the virtual network. | `string` | `null` | no |
| <a name="input_default_route"></a> [default\_route](#input\_default\_route) | Configuration for the default route. | <pre>object({<br>    name          = optional(string, "default-route")<br>    next_hop_type = optional(string, "VirtualAppliance")<br>    ip            = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_disable_bgp_route_propagation"></a> [disable\_bgp\_route\_propagation](#input\_disable\_bgp\_route\_propagation) | Disable Route Propagation. True = Disabled | `bool` | `true` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The DNS servers to use with this virtual network. | `list(string)` | `[]` | no |
| <a name="input_enable_network_watcher"></a> [enable\_network\_watcher](#input\_enable\_network\_watcher) | Enables Network Watcher for the region & subscription. | `bool` | `true` | no |
| <a name="input_extra_routes"></a> [extra\_routes](#input\_extra\_routes) | Routes to add to a custom route table. | <pre>map(object({<br>    address_prefix         = string<br>    next_hop_type          = optional(string, "VirtualAppliance")<br>    next_hop_in_ip_address = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_extra_subnets"></a> [extra\_subnets](#input\_extra\_subnets) | Subnets to create in this virtual network with the map name indicating the subnet name. | <pre>map(object({<br>    address_prefix                                = string<br>    service_endpoints                             = optional(list(string))<br>    private_endpoint_network_policies_enabled     = optional(bool)<br>    private_link_service_network_policies_enabled = optional(bool)<br>    associate_rt                                  = optional(bool, false)<br>    route_table_id                                = optional(string)<br><br>    delegations = optional(map(<br>      object({<br>        service = string<br>        actions = list(string)<br>      })<br>    ), {})<br>    associate_extra_subnets_route_table            = optional(bool, true)<br>    associate_extra_subnets_network_security_group = optional(bool, true)<br>  }))</pre> | `{}` | no |
| <a name="input_extra_subnets_network_security_group_name"></a> [extra\_subnets\_network\_security\_group\_name](#input\_extra\_subnets\_network\_security\_group\_name) | Name of the default Network Security Group | `string` | `"default-nsg"` | no |
| <a name="input_extra_subnets_route_table_name"></a> [extra\_subnets\_route\_table\_name](#input\_extra\_subnets\_route\_table\_name) | Name of the default Route Table | `string` | `null` | no |
| <a name="input_firewall"></a> [firewall](#input\_firewall) | Configuration for the firewall if enabled. | <pre>object({<br>    name               = string<br>    address_prefix     = string<br>    public_ip_name     = optional(string)<br>    sku_tier           = optional(string, "Standard")<br>    zone_redundant     = optional(bool, true)<br>    firewall_policy_id = optional(string)<br>    route_table_name   = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_flow_log"></a> [flow\_log](#input\_flow\_log) | Configuration for flow logs. | <pre>object({<br>    name                 = string<br>    storage_account_name = optional(string)<br>    storage_account_id   = optional(string)<br>    retention_days       = optional(number, 90)<br><br>    enable_analytics             = optional(bool)<br>    log_analytics_workspace_name = optional(string)<br>    analytics_interval_minutes   = optional(number)<br>    workspace_resource_id        = optional(string)<br>    workspace_id                 = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_include_azure_dns"></a> [include\_azure\_dns](#input\_include\_azure\_dns) | If using custom DNS servers, include Azure DNS IP as a DNS server. | `bool` | `false` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log analytics workspace ID to forward diagnostics to. | `string` | `null` | no |
| <a name="input_network_watcher_name"></a> [network\_watcher\_name](#input\_network\_watcher\_name) | Name of the Network Watcher | `string` | `null` | no |
| <a name="input_network_watcher_resource_group_name"></a> [network\_watcher\_resource\_group\_name](#input\_network\_watcher\_resource\_group\_name) | Name of the Network Watcher Resourece Group | `string` | `null` | no |
| <a name="input_nsg_rules_inbound"></a> [nsg\_rules\_inbound](#input\_nsg\_rules\_inbound) | A list of objects describing a rule inbound. | <pre>list(object({<br>    rule        = optional(string)<br>    name        = string<br>    description = optional(string, "Created by Terraform.")<br><br>    access   = optional(string, "Allow")<br>    priority = optional(number)<br><br>    protocol = optional(string, "*")<br>    ports    = optional(set(string), ["*"])<br><br>    source_prefixes      = optional(set(string), ["*"])<br>    destination_prefixes = optional(set(string), ["VirtualNetwork"])<br><br>    source_application_security_group_ids      = optional(set(string), null)<br>    destination_application_security_group_ids = optional(set(string), null)<br>  }))</pre> | `[]` | no |
| <a name="input_nsg_rules_outbound"></a> [nsg\_rules\_outbound](#input\_nsg\_rules\_outbound) | A list of objects describing a rule outbound. | <pre>list(object({<br>    rule        = optional(string)<br>    name        = string<br>    description = optional(string, "Created by Terraform.")<br><br>    access   = optional(string, "Allow")<br>    priority = optional(number)<br><br>    protocol = optional(string, "*")<br>    ports    = optional(set(string), ["*"])<br><br>    source_prefixes      = optional(set(string), ["*"])<br>    destination_prefixes = optional(set(string), ["VirtualNetwork"])<br><br>    source_application_security_group_ids      = optional(set(string), null)<br>    destination_application_security_group_ids = optional(set(string), null)<br>  }))</pre> | `[]` | no |
| <a name="input_private_dns_zones"></a> [private\_dns\_zones](#input\_private\_dns\_zones) | A set of private domains to configure. | <pre>map(object({<br>    resource_group_name  = optional(string)<br>    registration_enabled = optional(string, false)<br>    soa_record = optional(map(object({<br>      email        = string<br>      expire_time  = optional(number, 2419200)<br>      minimum_ttl  = optional(number, 10)<br>      refresh_time = optional(number, 3600)<br>      retry_time   = optional(number, 300)<br>      ttl          = optional(number, 3600)<br>      tags         = optional(map(string))<br>    })), {})<br>  }))</pre> | `{}` | no |
| <a name="input_private_endpoint_private_dns_zone_resource_group_name"></a> [private\_endpoint\_private\_dns\_zone\_resource\_group\_name](#input\_private\_endpoint\_private\_dns\_zone\_resource\_group\_name) | The name of the PE PDNS Resource Group. | `string` | `null` | no |
| <a name="input_private_endpoint_subnet"></a> [private\_endpoint\_subnet](#input\_private\_endpoint\_subnet) | Configuration for the Private Endpoint subnet. | <pre>object({<br>    subnet_name    = optional(string, "snet-pe")<br>    address_prefix = string<br>    service_endpoints = optional(list(string), [<br>      "Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB",<br>      "Microsoft.ContainerRegistry", "Microsoft.EventHub",<br>      "Microsoft.KeyVault", "Microsoft.ServiceBus",<br>      "Microsoft.Sql", "Microsoft.Storage",<br>      "Microsoft.Web"<br>    ])<br>  })</pre> | `null` | no |
| <a name="input_private_resolver"></a> [private\_resolver](#input\_private\_resolver) | Configuration for virtual network gateway if enabled. | <pre>object({<br>    name                    = string<br>    inbound_endpoint_name   = optional(string)<br>    inbound_subnet_name     = optional(string, "snet-dnspr-in")<br>    inbound_address_prefix  = string<br>    outbound_endpoint_name  = optional(string)<br>    outbound_subnet_name    = optional(string, "snet-dnspr-out")<br>    outbound_address_prefix = string<br>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to append to resources. | `map(string)` | `{}` | no |
| <a name="input_virtual_network_gateway"></a> [virtual\_network\_gateway](#input\_virtual\_network\_gateway) | Configuration for virtual network gateway if enabled. | <pre>object({<br>    name            = string<br>    address_prefix  = string<br>    public_ip_name  = optional(string)<br>    generation      = optional(string, "Generation1")<br>    sku             = optional(string, "VpnGw1")<br>    type            = optional(string, "Vpn")<br>    vpn_type        = optional(string, "RouteBased")<br>    public_ip_zones = optional(list(string))<br><br>    route_table = optional(object({<br>      name = string<br>      routes = optional(map(object({<br>        address_prefix         = string<br>        next_hop_type          = optional(string, "Internet")<br>        next_hop_in_ip_address = optional(string)<br>      })))<br>    }))<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion"></a> [bastion](#output\_bastion) | Output from the bastion module. |
| <a name="output_default_route_table"></a> [default\_route\_table](#output\_default\_route\_table) | Default route table passing traffic through the firewall. |
| <a name="output_firewall"></a> [firewall](#output\_firewall) | Output from the firewall. |
| <a name="output_id"></a> [id](#output\_id) | Output from the network module. |
| <a name="output_network"></a> [network](#output\_network) | Output from the network module. |
| <a name="output_network_watcher"></a> [network\_watcher](#output\_network\_watcher) | Output of the network watcher. |
| <a name="output_private_resolver"></a> [private\_resolver](#output\_private\_resolver) | Output from the private resolver. |
| <a name="output_private_resolver_inbound_endpoint"></a> [private\_resolver\_inbound\_endpoint](#output\_private\_resolver\_inbound\_endpoint) | Output from the private resolver inbound endpoint. |
| <a name="output_private_resolver_outbound_endpoint"></a> [private\_resolver\_outbound\_endpoint](#output\_private\_resolver\_outbound\_endpoint) | Output from the private resolver outbound endpoint. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Output of the Resource Group name created by the Hub module |
| <a name="output_route_table"></a> [route\_table](#output\_route\_table) | Output of the route table created in this module. |
| <a name="output_virtual_network_gateway"></a> [virtual\_network\_gateway](#output\_virtual\_network\_gateway) | Output from the virtual network gateway. |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.flow_log_law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_diagnostic_setting.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_network_watcher.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher) | resource |
| [azurerm_private_dns_resolver.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver) | resource |
| [azurerm_private_dns_resolver_inbound_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_inbound_endpoint) | resource |
| [azurerm_private_dns_resolver_outbound_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_outbound_endpoint) | resource |
| [azurerm_private_dns_zone.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.pe_pdns](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_public_ip.virtual_network_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.network_watcher](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_route_table.virtual_network_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_storage_account.flow_log_sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_virtual_network_gateway.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |
| [azurerm_location.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/location) | data source |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ans-coe/bastion/azurerm | 1.0.0 |
| <a name="module_extra_subnets_network_security_group"></a> [extra\_subnets\_network\_security\_group](#module\_extra\_subnets\_network\_security\_group) | ../network-security-group | n/a |
| <a name="module_extra_subnets_route_table"></a> [extra\_subnets\_route\_table](#module\_extra\_subnets\_route\_table) | ../route-table | n/a |
| <a name="module_firewall"></a> [firewall](#module\_firewall) | ../firewall | n/a |
| <a name="module_network"></a> [network](#module\_network) | ans-coe/virtual-network/azurerm | 1.3.0 |
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |