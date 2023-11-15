locals {
  default_app_settings = merge(
    var.zip_deploy_file != null ? {
      WEBSITE_RUN_FROM_PACKAGE = "1"
    } : {},
    var.create_application_insights ? {
      ApplicationInsightsAgent_EXTENSION_VERSION      = "~3"
      APPLICATIONINSIGHTS_CONNECTION_STRING           = one(azurerm_application_insights.main[*].connection_string)
      APPLICATIONINSIGHTS_CONFIGURATION_CONTENT       = ""
      APPINSIGHTS_INSTRUMENTATIONKEY                  = one(azurerm_application_insights.main[*].instrumentation_key)
      APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
      APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
      XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
      XDT_MicrosoftApplicationInsights_Mode           = "recommended"
      XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"
      DiagnosticServices_EXTENSION_VERSION            = "~3"
      InstrumentationEngine_EXTENSION_VERSION         = "disabled"
      SnapshotDebugger_EXTENSION_VERSION              = "disabled"
    } : {}
  )

  app_settings = merge(local.default_app_settings, var.app_settings)

  default_sticky_app_settings = concat(
    # Application Insights
    [
      "ApplicationInsightsAgent_EXTENSION_VERSION",
      "APPLICATIONINSIGHTS_CONNECTION_STRING",
      "APPLICATIONINSIGHTS_CONFIGURATION_CONTENT",
      "APPINSIGHTS_INSTRUMENTATIONKEY",
      "APPINSIGHTS_PROFILERFEATURE_VERSION",
      "APPINSIGHTS_SNAPSHOTFEATURE_VERSION",
      "XDT_MicrosoftApplicationInsights_BaseExtensions",
      "XDT_MicrosoftApplicationInsights_Mode",
      "XDT_MicrosoftApplicationInsights_PreemptSdk",
      "XDT_MicrosoftApplicationInsightsJava",
      "XDT_MicrosoftApplicationInsights_NodeJS",
      "DiagnosticServices_EXTENSION_VERSION",
      "InstrumentationEngine_EXTENSION_VERSION",
      "SnapshotDebugger_EXTENSION_VERSION"
    ],
    # Authentication
    [
      "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
    ]
  )
  sticky_app_settings = concat(local.default_sticky_app_settings, var.sticky_app_settings)

  ip_restriction_defaults = {
    action                    = "Allow"
    ip_address                = null
    virtual_network_subnet_id = null
    service_tag               = null
    headers                   = null
  }

  allowed_subnet_ids = [
    for id in var.allowed_subnet_ids
    : merge(local.ip_restriction_defaults, {
      name     = "ip_restriction_subnet_id_${join("", [1, index(var.allowed_subnet_ids, id)])}"
      priority = join("", [1, index(var.allowed_subnet_ids, id)])

      virtual_network_subnet_id = id
    })
  ]

  allowed_service_tags = [
    for st in var.allowed_service_tags
    : merge(local.ip_restriction_defaults, {
      name     = "ip_restriction_service_tag_${join("", [2, index(var.allowed_service_tags, st)])}"
      priority = join("", [2, index(var.allowed_service_tags, st)])

      service_tag = st
    })
  ]

  allowed_ips = [
    for ip in var.allowed_ips
    : merge(local.ip_restriction_defaults, {
      name     = "ip_restriction_cidr_${join("", [3, index(var.allowed_ips, ip)])}"
      priority = join("", [3, index(var.allowed_ips, ip)])

      ip_address = ip
    })
  ]

  allowed_frontdoor_ids = length(var.allowed_frontdoor_ids) == 0 ? [] : [
    merge(local.ip_restriction_defaults, {
      name     = "ip_restriction_frontdoor_5"
      priority = 5

      service_tag = "AzureFrontDoor.Backend"
      headers = [{
        x_azure_fdid      = var.allowed_frontdoor_ids
        x_fd_health_probe = null
        x_forwarded_for   = null
        x_forwarded_host  = null
      }]
    })
  ]

  access_rules = concat(
    local.allowed_subnet_ids, local.allowed_service_tags,
    local.allowed_ips, local.allowed_frontdoor_ids
  )

  allowed_scm_subnet_ids = [
    for id in var.allowed_scm_subnet_ids
    : merge(local.ip_restriction_defaults, {
      name     = "ip_restriction_subnet_id_${join("", [1, index(var.allowed_scm_subnet_ids, id)])}"
      priority = join("", [1, index(var.allowed_scm_subnet_ids, id)])

      virtual_network_subnet_id = id
    })
  ]

  allowed_scm_service_tags = [
    for st in var.allowed_scm_service_tags
    : merge(local.ip_restriction_defaults, {
      name     = "ip_restriction_service_tag_${join("", [2, index(var.allowed_scm_service_tags, st)])}"
      priority = join("", [2, index(var.allowed_scm_service_tags, st)])

      service_tag = st
    })
  ]

  allowed_scm_ips = [
    for ip in var.allowed_scm_ips
    : merge(local.ip_restriction_defaults, {
      name     = "scm_ip_restriction_cidr_${join("", [3, index(var.allowed_scm_ips, ip)])}"
      priority = join("", [3, index(var.allowed_scm_ips, ip)])

      ip_address = ip
    })
  ]

  scm_access_rules = concat(
    local.allowed_scm_subnet_ids, local.allowed_scm_service_tags,
    local.allowed_scm_ips
  )

  #### Keyvault

  // we replace _ with - for keyvault cert names but only in the value of the map. This is due to Keyvault limitations.
  kv_cert_map = { for c, v in var.ssl_certificates
    : c => replace(c, "_", "-") if alltrue([
      v.key_vault_secret_id == null,
      v.data == null,
      v.password == null
    ])
  }

  create_key_vault = alltrue([var.key_vault_id == null, var.use_key_vault])
}
