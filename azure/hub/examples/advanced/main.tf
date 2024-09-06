terraform {
  required_version = ">= 1.8.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.101"
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
    module     = "hub-example"
    example    = "advanced"
    usage      = "demo"
    department = "technical"
    owner      = "Dee Vops"
  }
  resource_prefix = "tfmex-adv"
}

resource "random_integer" "sa" {
  min = 1
  max = 999
}

######
# Hub
######

module "hub" {
  source = "../../"

  location = local.location
  tags     = local.tags

  resource_group_name  = "rg-hub-${local.resource_prefix}"
  virtual_network_name = "vnet-hub-${local.resource_prefix}"

  address_space     = ["10.0.0.0/16"]
  include_azure_dns = true

  firewall = {
    name               = "fw-hub-${local.resource_prefix}"
    address_prefix     = "10.0.0.0/26"
    public_ip_name     = "fw-pip-hub-${local.resource_prefix}"
    route_table_name   = "rt-hub-${local.resource_prefix}"
    firewall_policy_id = module.firewall-policy.id
  }

  bastion = {
    name                = "bas-hub-${local.resource_prefix}"
    resource_group_name = "rg-bas-${local.resource_prefix}"
    public_ip_name      = "pip-bas-hub-${local.resource_prefix}"
    address_prefix      = "10.0.0.64/27"
  }

  # Commented out as this takes ~30 mins to deploy.  Uncomment if specifically testing VNGs

  virtual_network_gateway = {
    name           = "vpngw-hub-${local.resource_prefix}"
    address_prefix = "10.0.0.96/27"
  }

  private_resolver = {
    name                    = "dnspr-hub-${local.resource_prefix}"
    inbound_address_prefix  = "10.0.0.128/28"
    outbound_address_prefix = "10.0.0.144/28"
  }

  create_private_endpoint_private_dns_zones = true

  private_endpoint_subnet = {
    name           = "sn-pe-${local.resource_prefix}"
    address_prefix = "10.0.1.0/24"
  }

  private_dns_zones = {
    "test.com" = {}
  }

  extra_subnets = {
    "sn-hub-keyvault-${local.resource_prefix}" = {
      address_prefix = "10.0.2.0/24"
    }
  }

  extra_subnets_network_security_group_name = "nsg-hub-keyvault-${local.resource_prefix}"
  nsg_rules_inbound = [
    {
      rule     = "https"
      name     = "AllowHttpsInBound"
      priority = 105
    }
  ]

  nsg_rules_outbound = [{
    name = "AllowALLOutBound"
  }]

  flow_log = {
    name                 = "fl-${local.resource_prefix}"
    storage_account_name = lower(replace("fl-sa-${local.resource_prefix}${random_integer.sa.result}", "/[-_]/", ""))

    enable_analytics             = true
    log_analytics_workspace_name = "fl-law-${local.resource_prefix}"
  }

  enable_network_watcher              = true
  network_watcher_name                = "nw-uks-hub-${local.resource_prefix}"
  network_watcher_resource_group_name = "rg-nw-hub-${local.resource_prefix}"
}

module "firewall-policy" {
  source = "../../../firewall-policy"

  name                     = "fwpol-hub-${local.resource_prefix}"
  resource_group_name      = module.hub.resource_group_name
  location                 = local.location
  tags                     = local.tags
  sku                      = "Standard"
  threat_intelligence_mode = "Alert"

  rule_collection_groups = {
    ApplicationOne = {
      priority = "100"
    }
  }
}

#########
# Spokes
#########

resource "azurerm_resource_group" "mgmt" {
  location = local.location
  name     = "rg-spoke-mgmt-${local.resource_prefix}"
  tags     = local.tags
}

module "spoke-mgmt" {
  source = "../../../spoke"

  location = local.location
  tags     = local.tags

  resource_group_name  = "rg-spoke-mgmt-${local.resource_prefix}"
  virtual_network_name = "vnet-spoke-mgmt-${local.resource_prefix}"

  enable_network_watcher = false

  address_space = ["10.1.0.0/16"]
  subnets = {
    "snet-mgmt-tfmex-adv-hub" = {
      address_prefixes = ["10.1.0.0/24"]
    }
  }

  vnet_peering = {
    hub = {
      remote_vnet_id      = module.hub.id
      use_remote_gateways = false
    }
  }

  network_security_group_name = "nsg-spoke-mgmt-${local.resource_prefix}"
  route_table_name            = "rt-spoke-mgmt-${local.resource_prefix}"
  default_route = {
    ip = module.hub.firewall.private_ip
  }
}

resource "azurerm_resource_group" "prd" {
  location = local.location
  name     = "rg-spoke-prd-${local.resource_prefix}"
  tags     = local.tags
}

module "spoke_prd" {
  source = "../../../spoke"

  location = local.location
  tags     = local.tags

  resource_group_name  = azurerm_resource_group.prd.name
  virtual_network_name = "vnet-spoke-prd-${local.resource_prefix}"

  enable_network_watcher = false

  address_space = ["10.2.0.0/16"]
  subnets = {
    "snet-prd-tfmex-adv-spoke" = {
      address_prefixes = ["10.2.0.0/24"]
    }
  }

  vnet_peering = {
    hub = {
      remote_vnet_id      = module.hub.id
      use_remote_gateways = false
    }
  }

  network_security_group_name = "nsg-spoke-prd-${local.resource_prefix}"
  route_table_name            = "rt-spoke-prd-${local.resource_prefix}"
  default_route = {
    ip = module.hub.firewall.private_ip
  }
}

##########
# Peering
##########

resource "azurerm_virtual_network_peering" "hub-mgmt" {
  name                         = "peer-hub-mgmt-${local.resource_prefix}"
  resource_group_name          = module.hub.network.resource_group_name
  virtual_network_name         = module.hub.network.name
  remote_virtual_network_id    = module.spoke-mgmt.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "mgmt-hub" {
  name                         = "peer-mgmt-hub-${local.resource_prefix}"
  resource_group_name          = module.spoke-mgmt.network.resource_group_name
  virtual_network_name         = module.spoke-mgmt.network.name
  remote_virtual_network_id    = module.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "hub-prd" {
  name                         = "peer-hub-prd-${local.resource_prefix}"
  resource_group_name          = module.hub.network.resource_group_name
  virtual_network_name         = module.hub.network.name
  remote_virtual_network_id    = module.spoke_prd.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "prd-hub" {
  name                         = "peer-prd-hub-${local.resource_prefix}"
  resource_group_name          = module.spoke_prd.network.resource_group_name
  virtual_network_name         = module.spoke_prd.network.name
  remote_virtual_network_id    = module.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}