###################
# Global Variables
###################

variable "name" {
  description = "Name"
  type        = string
}

variable "location" {
  description = "The location of created resources."
  type        = string
  default     = "uksouth"
}

variable "resource_group_name" {
  description = "The name of the resource group this module will use."
  type        = string
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = null
}

#############
# Firewall 
#############

variable "sku" {
  description = "The SKU Tier of the Firewall Policy. Possible values are Standard, Premium and Basic"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium", "Basic"], var.sku)
    error_message = "SKU must be either Standard, Premium or Basic"
  }
}

variable "base_policy_id" {
  description = "The ID of the base/parent Firewall Policy"
  type        = string
  default     = null
}

variable "dns" {
  description = "Whether to enable DNS proxy on Firewalls attached to this Firewall Policy and a list of custom DNS Server IPs"
  type = object({
    servers       = optional(list(string))
    proxy_enabled = optional(bool, true)
  })
  default = {}
}

variable "threat_intelligence_mode" {
  description = "The operation mode for Threat Intelligence. Possible values are Alert, Deny and Off"
  type        = string
  default     = "Alert"
}

variable "threat_intelligence_allowlist" {
  description = "A list of FQDNs, IPs or CIDR ranges that will be skipped for threat detection."
  type = object({
    ip_addresses = optional(list(string), [])
    fqdns        = optional(list(string), [])
  })
  default = null
}

variable "intrusion_detection" {
  description = "Configuration details for IDPS"
  type = object({
    mode                = optional(string, "Alert")
    signature_overrides = optional(map(string), {})
    traffic_bypass = optional(map(object({
      description           = optional(string)
      protocol              = string
      destination_addresses = optional(list(string))
      destination_ip_groups = optional(list(string))
      destination_ports     = optional(list(string))
      source_addresses      = optional(list(string))
      source_ip_groups      = optional(list(string))
    })), {})
    private_ranges = optional(list(string))
  })
  default = null

  validation {
    error_message = "The value for intrusion_detection.mode must be 'Off', 'Alert' or 'Deny'."
    condition     = var.intrusion_detection == null || can(contains(["Off", "Alert", "Deny"], var.intrusion_detection.mode))
  }
}

#############
# Monitoring
#############

variable "insights" {
  description = "Details for configuring a Log Analytics Workspace for the policy."
  type = object({
    enabled   = optional(bool, false)
    id        = optional(string)
    retention = optional(number, 30)

    log_analytics_workspace = optional(map(string), {})
  })
  default = null
}

#############
# Firewall Policy
#############


variable "rule_collection_groups" {
  description = "Rule Collection Groups"
  type = map(object({
    priority = number

    application_rule_collections = optional(map(object({
      description = optional(string)
      action      = string
      priority    = number
      rules = map(object({
        protocols             = optional(map(string), {}) #Http, Https
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_addresses = optional(list(string))
        destination_urls      = optional(list(string))
        destination_fqdns     = optional(list(string))
        destination_fqdn_tags = optional(list(string))
      }))
    })), {})

    network_rule_collections = optional(map(object({
      description = optional(string)
      action      = string
      priority    = number
      rules = map(object({
        protocols             = list(string) #Any, TCP, UDP, ICMP
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_addresses = optional(list(string))
        destination_ip_groups = optional(list(string))
        destination_fqdns     = optional(list(string))
        destination_ports     = optional(list(string), [])
      }))
    })), {})

    nat_rule_collections = optional(map(object({
      description = optional(string)
      priority    = number
      action      = optional(string, "Dnat") #Dnat only
      rules = map(object({
        protocols           = list(string) #TCP or UDP
        source_addresses    = optional(list(string))
        source_ip_groups    = optional(list(string))
        destination_address = optional(string)
        destination_ports   = optional(list(number))
        translated_address  = optional(string)
        translated_fqdn     = optional(string)
        translated_port     = optional(number)
      }))
    })), {})
  }))
  default = {}
}