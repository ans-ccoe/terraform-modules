########################
# Power Management Role
########################

resource "azurerm_role_definition" "power_management" {
  name        = "Power Management - ${var.name}"
  description = "This custom role provides ${var.name} permissions to read, start and stop Virtual Machines, Virtual Machine Scale Sets, Kubernetes Services, Web Apps and Web App Slots."

  scope = var.custom_role_scope != null ? var.custom_role_scope : data.azurerm_subscription.current.id

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Compute/virtualMachines/deallocate/action",
      "Microsoft.Compute/virtualMachineScaleSets/read",
      "Microsoft.Compute/virtualMachineScaleSets/start/action",
      "Microsoft.Compute/virtualMachineScaleSets/powerOff/action",
      "Microsoft.Compute/virtualMachineScaleSets/deallocate/action",
      "Microsoft.Web/sites/Read",
      "Microsoft.Web/sites/start/Action",
      "Microsoft.Web/sites/stop/Action",
      "Microsoft.Web/sites/slots/Read",
      "Microsoft.Web/sites/slots/start/Action",
      "Microsoft.Web/sites/slots/stop/Action",
      "Microsoft.ContainerService/managedClusters/read",
      "Microsoft.ContainerService/managedClusters/start/action",
      "Microsoft.ContainerService/managedClusters/stop/action"
    ]
  }
}

#####################
# Automation Account
#####################

resource "azurerm_automation_account" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku_name = "Basic"

  identity { type = "SystemAssigned" }
}

resource "azurerm_automation_schedule" "weekdays" {
  for_each = var.scheduled_hours

  name                    = "weekdays-${each.key}"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.main.name
  description             = format("This schedule runs once a day every weekday in %s.", var.timezone)

  timezone = var.timezone
  # Ugly logic, but pull tomorrow from locals and substring the 24 hour date formatted date.
  start_time = format(
    "%sT%s:%s:00Z", local.tomorrow, substr(each.value, 0, 2), substr(each.value, 2, 4)
  )

  frequency = "Week"
  week_days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  interval  = 1
}

resource "azurerm_role_assignment" "power_management" {
  for_each = toset(formatlist("/subscriptions/%s", var.managed_subscription_ids))

  description        = "Allow the automation account ${azurerm_automation_account.main.name} privileges to read, start and stop this resources under this scope."
  principal_id       = one(azurerm_automation_account.main.identity[*].principal_id)
  scope              = each.value
  role_definition_id = azurerm_role_definition.power_management.role_definition_resource_id

  skip_service_principal_aad_check = true
}

##########
# Runbook
##########

resource "azurerm_automation_runbook" "power_management" {
  for_each = toset(["AzVM", "AzVmss", "AzWebApp", "AzWebAppSlot", "AzAksCluster"])

  name                    = "ManagePower-${each.value}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.main.name
  tags                    = var.tags
  description             = "This runbook is used to manage power state for ${each.value} resources."

  runbook_type = "PowerShellWorkflow"
  content = templatefile(
    format("%s/templates/ManagePower-%s.ps1", path.module, each.value),
    { subscription_id = data.azurerm_subscription.current.subscription_id }
  )

  log_verbose  = var.log_verbose
  log_progress = var.log_progress
}
