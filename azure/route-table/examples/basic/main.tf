terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.86"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  location = "uksouth"
  tags = {
    module     = "route-table"
    example    = "basic"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-basic-rt"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_prefix}"
  location = local.location
  tags     = local.tags
}

module "network" {
  source  = "ans-coe/virtual-network/azurerm"
  version = "1.3.0"

  name                = "vnet-${local.resource_prefix}"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  address_space = ["10.0.0.0/16"]
  subnets = {
    snet-prod = {
      prefix = "10.0.0.0/24"
    }
  }
}

module "route-table" {
  source = "../.."

  name                = "rt-${local.resource_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  subnet_ids = [module.network.subnets["snet-prod"].id]

  default_route = {
    next_hop_in_ip_address = "1.2.3.4"
  }
}