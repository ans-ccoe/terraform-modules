# Terraform (Module) - Azure - Route Table

#### Table of Contents

- [Terraform (Module) - Azure - NAME](#terraform-module---azure---name)
      - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
  - [Requirements](#requirements)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Resources](#resources)
  - [Modules](#modules)

## Usage

This module creates a route table, routes and associates any subnet ids provided.

There is the option to create a "default route" which routes all IPs (0.0.0.0/0) to a specified default_route_ip.  If no IP is specified, no route is created.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the Route Table | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | n/a | yes |
| <a name="input_default_route"></a> [default\_route](#input\_default\_route) | Configuration for the default route. | <pre>object({<br>    name                   = optional(string, "default-route")<br>    next_hop_type          = optional(string, "VirtualAppliance")<br>    next_hop_in_ip_address = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_disable_bgp_route_propagation"></a> [disable\_bgp\_route\_propagation](#input\_disable\_bgp\_route\_propagation) | Disable Route Propagation for the Route Table. True = Disabled | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_routes"></a> [routes](#input\_routes) | Details of a route to be added to the Route Table with the name of the route as the key. | <pre>map(object({<br>    address_prefix         = string<br>    next_hop_type          = optional(string, "VirtualAppliance")<br>    next_hop_in_ip_address = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of Subnet IDs to associate with this Route Table. | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bgp_route_propagation_enabled"></a> [bgp\_route\_propagation\_enabled](#output\_bgp\_route\_propagation\_enabled) | The output of whether BGP Route Propagation is enabled or not. |
| <a name="output_id"></a> [id](#output\_id) | ID of the route table. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The output of the resource group. |
| <a name="output_route_table"></a> [route\_table](#output\_route\_table) | The output of the route table resource. |
| <a name="output_routes"></a> [routes](#output\_routes) | The output of routes. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | The output of subnets that are associated with this Route Table. |

## Resources

| Name | Type |
|------|------|
| [azurerm_route.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route_table.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet_route_table_association.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |