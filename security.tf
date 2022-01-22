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

resource "azurerm_storage_account" "secops" {
  name                     = "sa${local.resource_name_unique}"
  resource_group_name      = azurerm_resource_group.secops.name
  location                 = azurerm_resource_group.secops.location
  account_tier             = "Standard"
  account_replication_type = "GRS" #"GRS"
  tags                     = var.tags
}

resource "azurerm_advanced_threat_protection" "secops" {
  target_resource_id = azurerm_storage_account.secops.id
  enabled            = true
}

resource "azurerm_security_center_contact" "secops" {
  email = var.azure_defender_contact.email
  phone = var.azure_defender_contact.phone

  alert_notifications = true
  alerts_to_admins    = true
}

# resource "azurerm_key_vault" "secops" {
#   name                        = "kv-${local.resource_name}"
#   resource_group_name         = azurerm_resource_group.secops.name
#   location                    = azurerm_resource_group.secops.location
#   enabled_for_disk_encryption = true
#   tenant_id                   = data.azurerm_client_config.current.tenant_id
#   soft_delete_retention_days  = 7
#   purge_protection_enabled    = false

#   sku_name = "standard"

#   access_policy {
#     tenant_id = data.azurerm_client_config.current.tenant_id
#     object_id = data.azurerm_client_config.current.object_id

#     certificate_permissions = [
#       "backup",
#       "create",
#       "delete",
#       "deleteissuers",
#       "get",
#       "getissuers",
#       "import",
#       "list",
#       "listissuers",
#       "managecontacts",
#       "manageissuers",
#       "purge",
#       "recover",
#       "restore",
#       "setissuers",
#       "update"
#     ]
#     key_permissions = [
#       "backup",
#       "create",
#       "decrypt",
#       "delete",
#       "encrypt",
#       "get",
#       "import",
#       "list",
#       "purge",
#       "recover",
#       "restore",
#       "sign",
#       "unwrapKey",
#       "update",
#       "verify",
#       "wrapKey"
#     ]
#     secret_permissions = [
#       "backup",
#       "delete",
#       "get",
#       "list",
#       "purge",
#       "recover",
#       "restore",
#       "set"
#     ]
#     storage_permissions = [
#       "backup",
#       "delete",
#       "deletesas",
#       "get",
#       "getsas",
#       "list",
#       "listsas",
#       "purge",
#       "recover",
#       "regeneratekey",
#       "restore",
#       "set",
#       "setsas",
#       "update"
#     ]
#   }
# }


# resource "azurerm_application_insights" "secops" {
#   name                = "ai-${local.resource_name_unique}"
#   resource_group_name = azurerm_resource_group.secops.name
#   location            = azurerm_resource_group.secops.location
#   application_type    = "other"
# }

# resource "azurerm_container_registry" "secops" {
#   name                = "acr${local.resource_name_unique}"
#   resource_group_name = azurerm_resource_group.secops.name
#   location            = azurerm_resource_group.secops.location
#   sku                 = "Premium"
#   admin_enabled       = false

#   georeplications = [
#     {
#       location                  = "eastus2"
#       zone_redundancy_enabled   = true
#       regional_endpoint_enabled = true
#       tags                      = {}
#     }
#   ]
# }

# resource "azurerm_log_analytics_data_export_rule" "mgmt" {
#   name                    = "logexport1"
#   resource_group_name     = azurerm_resource_group.mgmt.name
#   workspace_resource_id   = azurerm_log_analytics_workspace.mgmt.id
#   destination_resource_id = azurerm_storage_account.mgmt.id
#   table_names             = ["Heartbeat"]
# }

# module "sc" {
#   for_each                            = var.azure_defender_subscriptions
#   source                              = "./modules/securitycenter"
#   subscription_id                     = each.value
#   storage_resource_id                 = azurerm_storage_account.secops.id
#   log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.secops.id
# }

# module "sc1" {
#   source                              = "./modules/securitycenter"
#   subscription_id                     = var.azure_defender_subscriptions[0]
#   storage_resource_id                 = azurerm_storage_account.secops.id
#   log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.secops.id
# }

# module "sc2" {
#   source                              = "./modules/securitycenter"
#   subscription_id                     = var.azure_defender_subscriptions[1]
#   storage_resource_id                 = azurerm_storage_account.secops.id
#   log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.secops.id
# }

# module "sc3" {
#   source                              = "./modules/securitycenter"
#   subscription_id                     = var.azure_defender_subscriptions[2]
#   storage_resource_id                 = azurerm_storage_account.secops.id
#   log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.secops.id
# }

# module "sc4" {
#   source                              = "./modules/securitycenter"
#   subscription_id                     = var.azure_defender_subscriptions[3]
#   storage_resource_id                 = azurerm_storage_account.secops.id
#   log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.secops.id
# }

# module "sc5" {
#   source                              = "./modules/securitycenter"
#   subscription_id                     = var.azure_defender_subscriptions[4]
#   storage_resource_id                 = azurerm_storage_account.secops.id
#   log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.secops.id
# }

# module "sc6" {
#   source                              = "./modules/securitycenter"
#   subscription_id                     = var.azure_defender_subscriptions[5]
#   storage_resource_id                 = azurerm_storage_account.secops.id
#   log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.secops.id
# }

# module "sc7" {
#   source                              = "./modules/securitycenter"
#   subscription_id                     = var.azure_defender_subscriptions[6]
#   storage_resource_id                 = azurerm_storage_account.secops.id
#   log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.secops.id
# }

# module "sc8" {
#   source                              = "./modules/securitycenter"
#   subscription_id                     = var.azure_defender_subscriptions[7]
#   storage_resource_id                 = azurerm_storage_account.secops.id
#   log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.secops.id
# }