provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "0.3.3"

  # Mandatory Variables
  root_parent_id = data.azurerm_client_config.current.tenant_id

  # Optional Variables
  root_id                   = local.root_id      // Define a custom ID to use for the root Management Group. Also used as a prefix for all core Management Group IDs.
  root_name                 = local.root_name    // Define a custom "friendly name" for the root Management Group
  deploy_core_landing_zones = true               // Control whether to deploy the default core landing zones // default = true
  deploy_demo_landing_zones = false              // Control whether to deploy the demo landing zones (default = false)
  library_path              = "${path.root}/lib" // Set a path for the custom archetype library path
  default_location          = local.default_location

  custom_landing_zones = {
    cu-demo = {
      display_name               = "Demo"
      parent_management_group_id = "cu-sandboxes"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "cu_demo"
        parameters = {
          CU-Deny-Resources = {
            listOfResourceTypesAllowed = local.allowed_resources
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
      subscription_ids           = local.sde_subs
      archetype_config = {
        archetype_id = "cu_sde_hipaa"
        parameters = {
          CU-Audit-HIPAA = {
            installedApplicationsOnWindowsVM                              = "*"
            DeployDiagnosticSettingsforNetworkSecurityGroupsstoragePrefix = local.secops_nsg_storage_prefix
            DeployDiagnosticSettingsforNetworkSecurityGroupsrgName        = local.secops_nsg_rg_name
            CertificateThumbprints                                        = "Nothing"
            workspaceId                                                   = local.secops_log_analytics_workspace_id
            listOfLocations                                               = local.allowed_locations
          }
        }
        access_control = {}
      }
    }

    cu-sde-nist = {
      display_name               = "NIST 800-171 R2"
      parent_management_group_id = "cu-sde"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "cu_sde_nist"
        parameters = {
          CU-Audit-NIST-800-171 = {
            membersToExcludeInLocalAdministratorsGroup = "nonadmin"
            membersToIncludeInLocalAdministratorsGroup = "admin"
            logAnalyticsWorkspaceIDForVMAgents         = local.secops_log_analytics_workspace_id
            listOfLocationsForNetworkWatcher           = local.allowed_locations
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
          listOfAllowedLocations = concat(["global"],local.allowed_locations)
        }

        Deny-RSG-Locations = {
          listOfAllowedLocations = concat(["global"], local.allowed_locations)
        }

        Deny-Subnet-Without-Nsg = {
          effect = "Audit"
        }

        Deploy-ASC-Monitoring = {
          networkWatcherShouldBeEnabledListOfLocations = local.allowed_locations
        }

        Deploy-AzActivity-Log = {
          logAnalytics = local.secops_log_analytics_workspace_resource_id
        }

        Deploy-LX-Arc-Monitoring = {
          logAnalytics = local.secops_log_analytics_workspace_resource_id
        }

        Deploy-Resource-Diag = {
          logAnalytics = local.secops_log_analytics_workspace_resource_id
        }

        Deploy-VM-Monitoring = {
          logAnalytics_1 = local.secops_log_analytics_workspace_resource_id
        }

        Deploy-VMSS-Monitoring = {
          logAnalytics_1 = local.secops_log_analytics_workspace_resource_id
        }

        Deploy-WS-Arc-Monitoring = {
          logAnalytics = local.secops_log_analytics_workspace_resource_id
        }

        CU-Audit-CIS = {
          listOfRegionsWhereNetworkWatcherShouldBeEnabled = local.allowed_locations
          listOfApprovedVMExtensions                      = local.allowed_vm_extensions
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
  }

  subscription_id_overrides = {
    root           = []
    decommissioned = []
    sandboxes      = []
    landing-zones  = []
    platform       = []
    connectivity   = local.connectivity_subs
    management     = []
    identity       = []
  }
}

# TODO: Grant all managed identities for CU-Deploy-Diag-* policies Log Analytics Contributor access to centralized Log Analytics Workspace

# module "budgets" {
#   source          = "./modules/budgets"
#   count           = length(local.connectivity_subs)
#   subscription_id = local.connectivity_subs[count.index]
# }