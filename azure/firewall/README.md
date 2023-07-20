# Terraform (Module) - PLATFORM - NAME

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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.22 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_dns_servers"></a> [firewall\_dns\_servers](#input\_firewall\_dns\_servers) | List of DNS Servers for Firewall config | `list(string)` | n/a | yes |
| <a name="input_firewall_name"></a> [firewall\_name](#input\_firewall\_name) | Name of the Azure Firewall | `string` | n/a | yes |
| <a name="input_firewall_sku_name"></a> [firewall\_sku\_name](#input\_firewall\_sku\_name) | Properties relating to the SKU Name of the Firewall | `string` | `"AZFW_VNet"` | no |
| <a name="input_firewall_sku_tier"></a> [firewall\_sku\_tier](#input\_firewall\_sku\_tier) | Properties relating to the SKU Tier of the Firewall | `string` | `"Standard"` | no |
| <a name="input_location"></a> [location](#input\_location) | The location of created resources. | `string` | `"uksouth"` | no |
| <a name="input_pip_name"></a> [pip\_name](#input\_pip\_name) | Name of the Firewall's public IP | `any` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group this module will use. | `string` | `null` | no |
| <a name="input_subnet_address_prefix"></a> [subnet\_address\_prefix](#input\_subnet\_address\_prefix) | The Subnet used the Firewall must have the name `AzureFirAzureFirewallSubnet` and a subnet mask of at least /26 | `list` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `null` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of your Azure Virtual Network | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_id"></a> [firewall\_id](#output\_firewall\_id) | The ID of the Azure Firewall |
| <a name="output_firewall_name"></a> [firewall\_name](#output\_firewall\_name) | The name of the Azure Firewall. |
| <a name="output_firewall_public_ip"></a> [firewall\_public\_ip](#output\_firewall\_public\_ip) | The public ip of firewall. |

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_public_ip.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_subnet.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
_______________
| Classified  |
| :---------: |
|   PUBLIC    |