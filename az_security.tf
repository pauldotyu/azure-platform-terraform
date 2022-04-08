resource "random_pet" "p" {
  length    = 1
  separator = ""
}

resource "random_integer" "i" {
  min = 000
  max = 999
}

locals {
  resource_name        = format("%s%s", "secops", random_pet.p.id)
  resource_name_unique = format("%s%s%s", "secops", random_pet.p.id, random_integer.i.result)
}

resource "azurerm_resource_group" "secops" {
  name     = "rg-${local.resource_name}"
  location = var.default_location
  tags     = var.tags
}

# https://docs.microsoft.com/en-us/azure/azure-monitor/monitor-reference
resource "azurerm_log_analytics_workspace" "secops" {
  name                = "law${local.resource_name_unique}"
  resource_group_name = azurerm_resource_group.secops.name
  location            = azurerm_resource_group.secops.location
  sku                 = "pergb2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_log_analytics_datasource_windows_event" "secops" {
  name                = "law${local.resource_name_unique}-windowsevents"
  resource_group_name = azurerm_resource_group.secops.name
  workspace_name      = azurerm_log_analytics_workspace.secops.name
  event_log_name      = "System"
  event_types = [
    "error",
    "warning",
    "information"
  ]
}

resource "azurerm_log_analytics_datasource_windows_performance_counter" "secops" {
  name                = "law${local.resource_name_unique}-windowsperf"
  resource_group_name = azurerm_resource_group.secops.name
  workspace_name      = azurerm_log_analytics_workspace.secops.name
  object_name         = "CPU"
  instance_name       = "*"
  counter_name        = "CPU"
  interval_seconds    = 60
}

#tfsec:ignore:azure-storage-queue-services-logging-enabled
resource "azurerm_storage_account" "secops" {
  name                     = "sa${local.resource_name_unique}"
  resource_group_name      = azurerm_resource_group.secops.name
  location                 = azurerm_resource_group.secops.location
  account_tier             = "Standard"
  account_replication_type = "GRS" #"GRS"
  tags                     = var.tags
  min_tls_version          = "TLS1_2"
}

resource "azurerm_advanced_threat_protection" "secops" {
  target_resource_id = azurerm_storage_account.secops.id
  enabled            = true
}

# resource "azurerm_security_center_contact" "secops" {
#   email = var.azure_defender_contact.email
#   phone = var.azure_defender_contact.phone

#   alert_notifications = true
#   alerts_to_admins    = true
# }

# resource "azurerm_log_analytics_data_export_rule" "secops" {
#   name                    = "law${local.resource_name_unique}-dataexport"
#   resource_group_name     = azurerm_resource_group.secops.name
#   workspace_resource_id   = azurerm_log_analytics_workspace.secops.id
#   destination_resource_id = azurerm_storage_account.secops.id
#   table_names             = ["Heartbeat", "SecurityEvent"]
#   enabled                 = true
# }

# resource "azurerm_security_center_workspace" "secops" {
#   for_each     = { for s in data.azurerm_subscriptions.available.subscriptions : s.id => s }
#   scope        = each.value["id"]
#   workspace_id = azurerm_log_analytics_workspace.secops.id
# }

provider "azurerm" {
  features {}
  alias           = "devops"
  subscription_id = var.devops_subscription_id
}

data "azurerm_key_vault" "devops" {
  provider            = azurerm.devops
  name                = var.devops_keyvault_name
  resource_group_name = var.devops_keyvault_rg_name
}

#tfsec:ignore:azure-keyvault-ensure-secret-expiry
resource "azurerm_key_vault_secret" "secops_law_workspace_id" {
  provider     = azurerm.devops
  name         = "secops-law-workspace-id"
  value        = azurerm_log_analytics_workspace.secops.workspace_id
  key_vault_id = data.azurerm_key_vault.devops.id
  content_type = "plaintext"
}


#tfsec:ignore:azure-keyvault-ensure-secret-expiry
resource "azurerm_key_vault_secret" "secops_law_workspace_key" {
  provider     = azurerm.devops
  name         = "secops-law-workspace-key"
  value        = azurerm_log_analytics_workspace.secops.primary_shared_key
  key_vault_id = data.azurerm_key_vault.devops.id
  content_type = "plaintext"
}