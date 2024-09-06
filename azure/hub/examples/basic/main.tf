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
    module     = "hub-example"
    example    = "basic"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-basic"
}

module "hub" {
  source = "../../"

  location = local.location
  tags     = local.tags

  resource_group_name  = "rg-hub-${local.resource_prefix}"
  virtual_network_name = "vnet-hub-${local.resource_prefix}"

  address_space = ["10.0.0.0/16"]
  extra_subnets = {
    "snet-hub" = {
      address_prefix = "10.0.1.0/24"
    }
  }

  firewall = {
    name           = "fw-hub-${local.resource_prefix}"
    address_prefix = "10.0.0.0/26"
  }

  bastion = {
    name                  = "bas-hub-${local.resource_prefix}"
    address_prefix        = "10.0.0.64/27"
    create_resource_group = false
  }

  # Commented out as this takes ~30 mins to deploy.  Uncomment if specifically testing VNGs

  # virtual_network_gateway = {
  #   name          = "vpngw-hub-${local.resource_prefix}"
  #   address_prefix = "10.0.0.96/27"
  # }

  private_resolver = {
    name                    = "dnspr-hub-${local.resource_prefix}"
    inbound_address_prefix  = "10.0.0.128/28"
    outbound_address_prefix = "10.0.0.144/28"
  }

  enable_network_watcher = false
  # network_watcher_name                = "nw_uks-${local.resource_prefix}"
  # network_watcher_resource_group_name = "rg-nw-${local.resource_prefix}"
}