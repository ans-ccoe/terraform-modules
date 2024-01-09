##########
# Insights
##########

resource "azurerm_log_analytics_workspace" "main" {
  count = var.create_application_insights ? 1 : 0

  name                = "log-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku               = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_application_insights" "main" {
  count = var.create_application_insights ? 1 : 0

  name                = "appi-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  application_type = "web"
  workspace_id     = one(azurerm_log_analytics_workspace.main[*].id)
}

###############
# Service Plan
###############

resource "azurerm_service_plan" "main" {
  count = var.plan["create"] ? 1 : 0

  name                = var.plan["name"] == null ? "asp-${var.name}" : var.plan["name"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku_name = var.plan["sku_name"]

  os_type                = "Windows"
  zone_balancing_enabled = var.plan["zone_balancing"]
}

locals {
  plan_id = coalesce(one(azurerm_service_plan.main[*].id), var.plan["id"])
}

#########
# Webapp
#########

resource "azurerm_windows_web_app" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  service_plan_id           = local.plan_id
  virtual_network_subnet_id = var.subnet_id

  https_only                      = true
  key_vault_reference_identity_id = var.key_vault_identity_id

  public_network_access_enabled = var.public_network_access_enabled

  zip_deploy_file = var.zip_deploy_file

  dynamic "site_config" {
    for_each = [var.site_config]
    content {
      application_stack {
        current_stack                = var.application_stack.current_stack
        docker_container_name        = var.application_stack.docker_container_name
        docker_container_tag         = var.application_stack.docker_container_tag
        docker_container_registry    = var.application_stack.docker_container_registry
        dotnet_version               = var.application_stack.dotnet_version
        dotnet_core_version          = var.application_stack.dotnet_core_version
        java_version                 = var.application_stack.java_version
        java_embedded_server_enabled = var.application_stack.java_embedded_server_enabled
        node_version                 = var.application_stack.node_version
        php_version                  = var.application_stack.php_version
        python                       = var.application_stack.python
        tomcat_version               = var.application_stack.tomcat_version
      }
      app_command_line = site_config.value.app_command_line

      worker_count           = site_config.value.worker_count
      use_32_bit_worker      = site_config.value.use_32_bit_worker
      local_mysql_enabled    = site_config.value.local_mysql_enabled
      always_on              = site_config.value.always_on
      vnet_route_all_enabled = site_config.value.vnet_route_all_enabled
      load_balancing_mode    = site_config.value.load_balancing_mode

      minimum_tls_version     = "1.2"
      scm_minimum_tls_version = "1.2"
      http2_enabled           = site_config.value.http2_enabled
      websockets_enabled      = site_config.value.websockets_enabled
      default_documents       = var.default_documents

      api_definition_url    = site_config.value.api_definition_url
      api_management_api_id = site_config.value.api_management_api_id

      health_check_path                 = site_config.value.health_check_path
      health_check_eviction_time_in_min = site_config.value.health_check_eviction_time_in_min

      container_registry_use_managed_identity       = site_config.value.container_registry_use_managed_identity
      container_registry_managed_identity_client_id = site_config.value.container_registry_managed_identity_client_id
      remote_debugging_enabled                      = site_config.value.remote_debugging_enabled
      remote_debugging_version                      = site_config.value.remote_debugging_version

      dynamic "cors" {
        for_each = var.cors == null ? [] : [1]
        content {
          allowed_origins     = var.cors.allowed_origins
          support_credentials = var.cors.support_credentials
        }
      }

      virtual_application {
        physical_path = var.virtual_application["physical_path"]
        preload       = var.virtual_application["preload"]
        virtual_path  = var.virtual_application["virtual_path"]
        dynamic "virtual_directory" {
          for_each = var.virtual_application["virtual_directories"]
          content {
            physical_path = virtual_directory.physical_path
            virtual_path  = virtual_directory.virtual_path
          }
        }
      }

      dynamic "ip_restriction" {
        for_each = local.access_rules
        content {
          name     = ip_restriction.name
          priority = ip_restriction.priority
          action   = ip_restriction.action

          ip_address                = ip_restriction.ip_address
          service_tag               = ip_restriction.service_tag
          virtual_network_subnet_id = ip_restriction.virtual_network_subnet_id
          headers                   = ip_restriction.headers
        }
      }
      dynamic "scm_ip_restriction" {
        for_each = local.scm_access_rules
        content {
          name     = scm_ip_restriction.name
          priority = scm_ip_restriction.priority
          action   = scm_ip_restriction.action

          ip_address                = scm_ip_restriction.ip_address
          service_tag               = scm_ip_restriction.service_tag
          virtual_network_subnet_id = scm_ip_restriction.virtual_network_subnet_id
          headers                   = scm_ip_restriction.headers
        }
      }
    }
  }

  app_settings = local.app_settings
  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value["name"]
      type  = connection_string.value["type"]
      value = connection_string.value["value"]
    }
  }
  dynamic "sticky_settings" {
    for_each = length(concat(local.sticky_app_settings, var.sticky_connection_strings)) == 0 ? [] : [1]
    content {
      app_setting_names       = length(local.sticky_app_settings) == 0 ? null : local.sticky_app_settings
      connection_string_names = length(var.sticky_connection_strings) == 0 ? null : var.sticky_connection_strings
    }
  }

  logs {
    detailed_error_messages = var.logs["detailed_error_messages"]
    failed_request_tracing  = var.logs["failed_request_tracing"]

    application_logs {
      file_system_level = var.logs["level"]
    }

    http_logs {
      file_system {
        retention_in_days = var.logs["retention_in_days"]
        retention_in_mb   = var.logs["retention_in_mb"]
      }
    }
  }

  identity {
    type         = length(var.identity_ids) == 0 ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to image tag, as this would be managed elsewhere.
      site_config[0].application_stack[0].docker_container_tag,
      # Ignore blob log configuration - ideally configure through diagnostic setting
      logs[0].application_logs[0].azure_blob_storage,
      logs[0].http_logs[0].azure_blob_storage,
      # Ignore hidden links that when deleted may break functionality
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      # Configure authentication outside of Terraform
      auth_settings_v2,
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
    ]
  }
}

resource "azurerm_windows_web_app_slot" "main" {
  for_each = var.slots

  name           = each.value
  app_service_id = azurerm_windows_web_app.main.id
  tags           = var.tags

  virtual_network_subnet_id = var.subnet_id

  https_only                      = true
  key_vault_reference_identity_id = var.key_vault_identity_id

  zip_deploy_file = var.zip_deploy_file

  dynamic "site_config" {
    for_each = [var.site_config]
    content {
      worker_count           = site_config.value.worker_count
      use_32_bit_worker      = site_config.value.use_32_bit_worker
      local_mysql_enabled    = site_config.value.local_mysql_enabled
      always_on              = site_config.value.always_on
      vnet_route_all_enabled = site_config.value.vnet_route_all_enabled
      load_balancing_mode    = site_config.value.load_balancing_mode

      minimum_tls_version     = "1.2"
      scm_minimum_tls_version = "1.2"
      http2_enabled           = site_config.value.http2_enabled
      websockets_enabled      = site_config.value.websockets_enabled
      default_documents       = var.default_documents

      api_definition_url    = site_config.value.api_definition_url
      api_management_api_id = site_config.value.api_management_api_id

      health_check_path                 = site_config.value.health_check_path
      health_check_eviction_time_in_min = site_config.value.health_check_eviction_time_in_min

      container_registry_use_managed_identity       = site_config.value.container_registry_use_managed_identity
      container_registry_managed_identity_client_id = site_config.value.container_registry_managed_identity_client_id
      remote_debugging_enabled                      = site_config.value.remote_debugging_enabled
      remote_debugging_version                      = site_config.value.remote_debugging_version

      dynamic "ip_restriction" {
        for_each = local.access_rules
        content {
          name     = ip_restriction.name
          priority = ip_restriction.priority
          action   = ip_restriction.action

          ip_address                = ip_restriction.ip_address
          service_tag               = ip_restriction.service_tag
          virtual_network_subnet_id = ip_restriction.virtual_network_subnet_id
          headers                   = ip_restriction.headers
        }
      }
      dynamic "scm_ip_restriction" {
        for_each = local.access_rules
        content {
          name     = scm_ip_restriction.name
          priority = scm_ip_restriction.priority
          action   = scm_ip_restriction.action

          ip_address                = scm_ip_restriction.ip_address
          service_tag               = scm_ip_restriction.service_tag
          virtual_network_subnet_id = scm_ip_restriction.virtual_network_subnet_id
          headers                   = scm_ip_restriction.headers
        }
      }

      dynamic "cors" {
        for_each = var.cors == null ? [] : [1]
        content {
          allowed_origins     = var.cors.allowed_origins
          support_credentials = var.cors.support_credentials
        }
      }

      application_stack {
        current_stack                = var.application_stack.current_stack
        docker_container_name        = var.application_stack.docker_container_name
        docker_container_tag         = var.application_stack.docker_container_tag
        docker_container_registry    = var.application_stack.docker_container_registry
        dotnet_version               = var.application_stack.dotnet_version
        dotnet_core_version          = var.application_stack.dotnet_core_version
        java_version                 = var.application_stack.java_version
        java_embedded_server_enabled = var.application_stack.java_embedded_server_enabled
        node_version                 = var.application_stack.node_version
        php_version                  = var.application_stack.php_version
        python                       = var.application_stack.python
        tomcat_version               = var.application_stack.tomcat_version
      }

      virtual_application {
        physical_path = var.virtual_application["physical_path"]
        preload       = var.virtual_application["preload"]
        virtual_path  = var.virtual_application["virtual_path"]
        dynamic "virtual_directory" {
          for_each = var.virtual_application["virtual_directories"]
          content {
            physical_path = virtual_directory.physical_path
            virtual_path  = virtual_directory.virtual_path
          }
        }
      }
    }
  }

  app_settings = local.app_settings
  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value["name"]
      type  = connection_string.value["type"]
      value = connection_string.value["value"]
    }
  }

  logs {
    detailed_error_messages = var.logs["detailed_error_messages"]
    failed_request_tracing  = var.logs["failed_request_tracing"]

    application_logs {
      file_system_level = var.logs["level"]
    }

    http_logs {
      file_system {
        retention_in_days = var.logs["retention_in_days"]
        retention_in_mb   = var.logs["retention_in_mb"]
      }
    }
  }

  identity {
    type         = length(var.identity_ids) == 0 ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.identity_ids
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to image tag, as this would be managed elsewhere.
      site_config[0].application_stack[0].docker_container_tag,
      # Ignore blob log configuration - ideally configure through diagnostic setting
      logs[0].application_logs[0].azure_blob_storage,
      logs[0].http_logs[0].azure_blob_storage,
      # Ignore hidden links that when deleted may break functionality
      tags["hidden-link: /app-insights-conn-string"],
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      # Configure authentication outside of Terraform
      auth_settings_v2,
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
    ]
  }
}