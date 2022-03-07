terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.98.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}
data "azurerm_subscriptions" "available" {}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "1.1.3"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }

  # Mandatory Variables
  root_parent_id = data.azurerm_client_config.current.tenant_id

  # Optional Variables
  root_id                   = var.root_id        // Define a custom ID to use for the root Management Group. Also used as a prefix for all core Management Group IDs.
  root_name                 = var.root_name      // Define a custom "friendly name" for the root Management Group
  deploy_core_landing_zones = true               // Control whether to deploy the default core landing zones // default = true
  deploy_demo_landing_zones = false              // Control whether to deploy the demo landing zones (default = false)
  library_path              = "${path.root}/lib" // Set a path for the custom archetype library path
  default_location          = var.default_location

  custom_landing_zones = {
    cu-restricted = {
      display_name               = "Restricted"
      parent_management_group_id = "cu-sandboxes"
      subscription_ids           = var.restricted_subs
      archetype_config = {
        archetype_id = "cu_restricted"
        parameters = {
          CU-Deny-Resources = {
            listOfResourceTypesAllowed = var.allowed_resources
          }
        }
        access_control = {}
      }
    }

    cu-sde = {
      display_name               = "Secure Data Enclave"
      parent_management_group_id = "cu-landing-zones"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "cu_sde"
        parameters = {
        }
        access_control = {}
      }
    }

    cu-sde-hipaa = {
      display_name               = "HITRUST/HIPAA"
      parent_management_group_id = "cu-sde"
      subscription_ids           = var.sde_hipaa_subs
      archetype_config = {
        archetype_id = "cu_sde_hipaa"
        parameters = {
          CU-Audit-HIPAA = {
            installedApplicationsOnWindowsVM                              = "*"
            DeployDiagnosticSettingsforNetworkSecurityGroupsstoragePrefix = "sa${local.resource_name_unique}"
            DeployDiagnosticSettingsforNetworkSecurityGroupsrgName        = azurerm_resource_group.secops.name
            CertificateThumbprints                                        = "Nothing"
            workspaceId                                                   = azurerm_log_analytics_workspace.secops.workspace_id
            listOfLocations                                               = var.allowed_locations
          }
        }
        access_control = {}
      }
    }

    cu-sde-nist = {
      display_name               = "NIST 800-171 R2"
      parent_management_group_id = "cu-sde"
      subscription_ids           = var.sde_nist_subs
      archetype_config = {
        archetype_id = "cu_sde_nist"
        parameters = {
          CU-Audit-NIST-800-171 = {
            membersToExcludeInLocalAdministratorsGroup = "nonadmin"
            membersToIncludeInLocalAdministratorsGroup = "admin"
            logAnalyticsWorkspaceIDForVMAgents         = azurerm_log_analytics_workspace.secops.workspace_id
            listOfLocationsForNetworkWatcher           = var.allowed_locations
          }
        }
        access_control = {}
      }
    }

    cu-sde-cmmc = {
      display_name               = "CMMC Level 3"
      parent_management_group_id = "cu-sde"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "cu_sde_cmmc"
        parameters = {
          CU-Audit-CMMC = {
            MembersToExclude-69bf4abd-ca1e-4cf6-8b5a-762d42e61d4f        = "nonadmin"
            MembersToInclude-30f71ea1-ac77-4f26-9fc5-2d926bbd4ba7        = "admin"
            logAnalyticsWorkspaceId-f47b5582-33ec-4c5c-87c0-b010a6b2e917 = azurerm_log_analytics_workspace.secops.workspace_id
          }
        }
        access_control = {}
      }
    }
  }

  archetype_config_overrides = {
    root = {
      archetype_id = "cu_root"
      parameters = {
        Deny-Resource-Locations = {
          listOfAllowedLocations = concat(["global"], var.allowed_locations)
        }

        Deny-RSG-Locations = {
          listOfAllowedLocations = concat(["global"], var.allowed_locations)
        }

        Deny-Subnet-Without-Nsg = {
          effect = "Audit"
        }

        Deploy-ASC-Monitoring = {
          networkWatcherShouldBeEnabledListOfLocations = var.allowed_locations
        }

        Deploy-ASCDF-Config = {
          emailSecurityContact           = var.azure_defender_contact.email
          logAnalytics                   = azurerm_log_analytics_workspace.secops.id
          ascExportResourceGroupName     = "DefenderExportRG"
          ascExportResourceGroupLocation = azurerm_resource_group.secops.location
          enableAscForKubernetes         = "DeployIfNotExists"
          enableAscForSql                = "DeployIfNotExists"
          enableAscForSqlOnVm            = "DeployIfNotExists"
          enableAscForDns                = "DeployIfNotExists"
          enableAscForArm                = "DeployIfNotExists"
          enableAscForOssDb              = "DeployIfNotExists"
          enableAscForAppServices        = "DeployIfNotExists"
          enableAscForRegistries         = "DeployIfNotExists"
          enableAscForKeyVault           = "DeployIfNotExists"
          enableAscForStorage            = "DeployIfNotExists"
          enableAscForServers            = "DeployIfNotExists"
        }

        Deploy-AzActivity-Log = {
          logAnalytics = azurerm_log_analytics_workspace.secops.id
        }

        Deploy-LX-Arc-Monitoring = {
          logAnalytics = azurerm_log_analytics_workspace.secops.id
        }

        Deploy-Resource-Diag = {
          logAnalytics = azurerm_log_analytics_workspace.secops.id
        }

        Deploy-VM-Monitoring = {
          logAnalytics_1 = azurerm_log_analytics_workspace.secops.id
        }

        Deploy-VMSS-Monitoring = {
          logAnalytics_1 = azurerm_log_analytics_workspace.secops.id
        }

        Deploy-WS-Arc-Monitoring = {
          logAnalytics = azurerm_log_analytics_workspace.secops.id
        }

        CU-Audit-Public-Blobs = {
          effect = "Audit"
        }
      }
      access_control = {}
    }

    management = {
      archetype_id   = "cu_management"
      parameters     = {}
      access_control = {}
    }

    landing-zones = {
      archetype_id   = "cu_landing_zones"
      parameters     = {}
      access_control = {}
    }

    identity = {
      archetype_id   = "cu_identity"
      parameters     = {}
      access_control = {}
    }

    connectivity = {
      archetype_id   = "cu_connectivity"
      parameters     = {}
      access_control = {}
    }
  }

  subscription_id_overrides = {
    root           = []
    decommissioned = []
    sandboxes      = var.sandbox_subs
    landing-zones  = var.landing_zone_subs
    platform       = var.platform_subs
    connectivity   = var.connectivity_subs
    management     = var.management_subs
    identity       = var.identity_subs
  }
}