# Terraform (Module) - Azure - Firewall

#### Table of Contents

1. [Usage](#usage)
2. [Requirements](#requirements)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Resources](#resources)
6. [Modules](#modules)

## Usage

This document will describe what the module is for and what is contained in it. It will be generated using [terraform-docs](https://terraform-docs.io/) which is configured to append to the existing README.md file.

Things to update:
- README.md header
- README.md header content - description of module and its purpose
- Update [terraform.tf](terraform.tf) required_versions
- Add a LICENSE to this module
- Update .tflint.hcl plugins if necessary
- If this module is to be created for use with Terraform Registry, ensure the repository itself is called `terraform-PROVIDER-NAME` for the publish step
- If this module is going to be a part of a monorepo, remove [.pre-commit-config.yaml](./.pre-commit-config.yaml)
- If using this for Terraform Configurations, optionally remove [examples](./examples/) and remove `.terraform.lock.hcl` from the [.gitignore](./.gitignore)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.93 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_name"></a> [firewall\_name](#input\_firewall\_name) | Name of the Azure Firewall | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location of the firewall. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_subnet_address_prefixes"></a> [subnet\_address\_prefixes](#input\_subnet\_address\_prefixes) | The subnet used for the firewall must have the name `AzureFirewallSubnet` and a subnet mask of at least /26 | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of your Azure Virtual Network | `string` | n/a | yes |
| <a name="input_default_route_name"></a> [default\_route\_name](#input\_default\_route\_name) | The name of the default route. | `string` | `"default-route"` | no |
| <a name="input_extra_routes"></a> [extra\_routes](#input\_extra\_routes) | Routes to add to a custom route table. | <pre>map(object({<br>    address_prefix         = string<br>    next_hop_type          = optional(string, "VirtualAppliance")<br>    next_hop_in_ip_address = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_firewall_dns_servers"></a> [firewall\_dns\_servers](#input\_firewall\_dns\_servers) | List of DNS Servers for Firewall config | `list(string)` | `null` | no |
| <a name="input_firewall_policy_id"></a> [firewall\_policy\_id](#input\_firewall\_policy\_id) | The ID of the Firewall Policy applied to this Firewall | `string` | `null` | no |
| <a name="input_firewall_sku_name"></a> [firewall\_sku\_name](#input\_firewall\_sku\_name) | Properties relating to the SKU Name of the Firewall | `string` | `"AZFW_VNet"` | no |
| <a name="input_firewall_sku_tier"></a> [firewall\_sku\_tier](#input\_firewall\_sku\_tier) | Properties relating to the SKU Tier of the Firewall | `string` | `"Standard"` | no |
| <a name="input_pip_name"></a> [pip\_name](#input\_pip\_name) | Name of the firewall's public IP | `string` | `null` | no |
| <a name="input_private_ip_ranges"></a> [private\_ip\_ranges](#input\_private\_ip\_ranges) | A list of SNAT private CIDR IP ranges, or the special string IANAPrivateRanges, which indicates Azure Firewall does not SNAT when the destination IP address is a private range per IANA RFC 1918. | `list(string)` | `null` | no |
| <a name="input_route_table_name"></a> [route\_table\_name](#input\_route\_table\_name) | The name of the route table to be created for the AzureFirewallSubnet. | `string` | `null` | no |
| <a name="input_zone_redundant"></a> [zone\_redundant](#input\_zone\_redundant) | Specifies whether or not the Firewall is Zone Redundant. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the Azure Firewall |
| <a name="output_name"></a> [name](#output\_name) | The name of the Azure Firewall. |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | The private IP Address of the firewall |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | The public IP Address of firewall. |
| <a name="output_route_table"></a> [route\_table](#output\_route\_table) | The attributes of the route table. |
| <a name="output_subnet"></a> [subnet](#output\_subnet) | The attributes of the created subnet |

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_public_ip.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_location.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/location) | data source |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_route-table"></a> [route-table](#module\_route-table) | ../route-table | n/a |
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |