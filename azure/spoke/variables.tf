###################
# Global Variables
###################

variable "location" {
  description = "The location of created resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = null
}

variable "resource_group_name" {
  description = "The name of the resource group this module will use."
  type        = string
}

##########
# Network
##########

variable "virtual_network_name" {
  description = "The name of the spoke virtual network."
  type        = string
}


variable "address_space" {
  description = "The address spaces of the virtual network."
  type        = list(string)

  validation {
    error_message = "Must be valid IPv4 CIDR."
    condition     = can(cidrhost(one(var.address_space[*]), 0))
  }
}

variable "dns_servers" {
  description = "The DNS servers to use with this virtual network."
  type        = list(string)
  default     = []
}

variable "include_azure_dns" {
  description = "If using custom DNS servers, include Azure DNS IP as a DNS server."
  type        = bool
  default     = false
}

variable "private_dns_zones" {
  description = "Private DNS Zones to link to this virtual network with the map name indicating the private dns zone name."
  type = map(object({
    resource_group_name  = string
    registration_enabled = optional(bool)
  }))
  default = {}
}

variable "disable_bgp_route_propagation" {
  description = "Disable Route Propagation. True = Disabled"
  type        = bool
  default     = true
}

variable "ddos_protection_plan_id" {
  description = "A DDoS Protection plan ID to assign to the virtual network."
  type        = string
  default     = null
}

variable "bgp_community" {
  description = "The BGP Community for this virtual network."
  type        = string
  default     = null
}

variable "subnets" {
  description = "Subnets to create in this virtual network with the map name indicating the subnet name."
  type = map(object({
    address_prefixes                              = list(string)
    resource_group_name                           = optional(string)
    service_endpoints                             = optional(list(string))
    private_endpoint_network_policies_enabled     = optional(bool)
    private_link_service_network_policies_enabled = optional(bool)
    delegations = optional(map(
      object({
        service = string
        actions = list(string)
      })
    ), {})
    associate_default_route_table            = optional(bool, true)
    associate_default_network_security_group = optional(bool, true)
  }))
  default = {}
}

#########################
# Network Security Group
#########################

variable "create_default_network_security_group" {
  description = "Create a Network Security Group to associate with all subnets."
  type        = bool
  default     = true
}

variable "network_security_group_name" {
  description = "Name of the default Network Security Group"
  type        = string
  default     = "default-nsg"
}

variable "nsg_rules_inbound" {
  description = "A list of objects describing a rule inbound."
  type = list(object({
    rule = optional(string)
    name = string
    # nsg_name    = string
    description = optional(string, "Created by Terraform.")

    access   = optional(string, "Allow")
    priority = optional(number)

    protocol = optional(string, "*")
    ports    = optional(set(string), ["*"])

    source_prefixes      = optional(set(string), ["*"])
    destination_prefixes = optional(set(string), ["VirtualNetwork"])

    source_application_security_group_ids      = optional(set(string), null)
    destination_application_security_group_ids = optional(set(string), null)
  }))
  default = []
}

variable "nsg_rules_outbound" {
  description = "A list of objects describing a rule outbound."
  type = list(object({
    rule = optional(string)
    name = string
    # nsg_name    = string
    description = optional(string, "Created by Terraform.")

    access   = optional(string, "Allow")
    priority = optional(number)

    protocol = optional(string, "*")
    ports    = optional(set(string), ["*"])

    source_prefixes      = optional(set(string), ["*"])
    destination_prefixes = optional(set(string), ["VirtualNetwork"])

    source_application_security_group_ids      = optional(set(string), null)
    destination_application_security_group_ids = optional(set(string), null)
  }))
  default = []
}

##############
# Route Table
##############

variable "create_default_route_table" {
  description = "Create a route table to associate with all subnets."
  type        = bool
  default     = true
}

variable "route_table_name" {
  description = "Name of the default Route Table"
  type        = string
  default     = "default-rt"
}


variable "default_route_name" {
  description = "Name of the default route."
  type        = string
  default     = "default-route"
}

variable "default_route_ip" {
  description = "Default route IP Address."
  type        = string

  default = null

  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.default_route_ip))
    error_message = "Invalid IP address provided."
  }
}

variable "routes" {
  description = "Routes to add to a custom route table."
  type = map(object({
    address_prefix         = string
    next_hop_type          = optional(string, "VirtualAppliance")
    next_hop_in_ip_address = optional(string)
  }))
  default = {}
}

##################
# Network Watcher
##################

variable "network_watcher_config" {
  description = "Configuration for the network watcher resource."
  type = object({
    name                = string
    resource_group_name = optional(string)
  })
  default = {
    name = null
    resource_group_name = null
  }
}

##########
# Peering
##########

variable "hub_peering" {
  description = "Config for peering to the hub network."
  type = map(object({
    id                           = string
    create_reverse_peering       = optional(bool, true)
    hub_resource_group_name      = string
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, true)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, true)
  }))
  default = {}
}