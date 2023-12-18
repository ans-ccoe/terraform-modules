terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.84"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  location = "uksouth"
  tags = {
    module     = "spoke-vnet"
    example    = "basic"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_infix = "tfmex-basic-spoke"
}

resource "azurerm_resource_group" "main_default" {
  name     = "rg-${local.resource_infix}-default"
  location = local.location
  tags     = local.tags
}

resource "azurerm_resource_group" "main_custom" {
  name     = "rg-${local.resource_infix}-custom"
  location = local.location
  tags     = local.tags
}

module "spoke" {
  source = "../../"

  location = local.location
  tags     = local.tags

  resource_group_name  = azurerm_resource_group.main_default.name
  virtual_network_name = "vnet-${local.resource_infix}-default"

  address_space = ["10.0.0.0/16"]
  subnets = {
    snet-default = {
      prefix             = "10.0.1.0/24"
      default_route_ip   = "192.168.0.1"
      default_route_name = "default_route_table"
    }
    snet-custom = {
      prefix                     = "10.0.2.0/24"
      resource_group_name        = azurerm_resource_group.main_custom.name
      create_default_route_table = false
      create_custom_route_table  = true
      custom_route_table_name    = "custom_route_table"
      default_route_ip           = "192.168.0.1"
      create_subnet_nsg = true
      subnet_nsg_name =   "nsg-${local.resource_infix}-custom"
    }
  }

  custom_routes = {
    custom_route_01 = {
      route_table_name       = "custom_route_table"
      address_prefix         = "0.0.0.0/0"
      next_hop_in_ip_address = "192.168.4.10"
    }
  }

  nsg_rules_inbound =  [{
    name        = "nsg_rule_in_1"
    nsg_name    = "nsg-${local.resource_infix}-custom"
    protocol = "Tcp"
    ports    = ["443"]
  }]

  nsg_rules_outbound = [{
    name        = "nsg_rule_out_1"
    nsg_name    = "nsg-${local.resource_infix}-custom"
  }]
}