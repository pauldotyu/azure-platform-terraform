terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.77.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_client_config" "current" {}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "1.1.1"

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
    cu-demo = {
      display_name               = "Demo"
      parent_management_group_id = "cu-sandboxes"
      subscription_ids           = []
      archetype_config = {
        archetype_id = "cu_demo"
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
            DeployDiagnosticSettingsforNetworkSecurityGroupsstoragePrefix = var.secops_nsg_storage_prefix
            DeployDiagnosticSettingsforNetworkSecurityGroupsrgName        = var.secops_nsg_rg_name
            CertificateThumbprints                                        = "Nothing"
            workspaceId                                                   = var.secops_log_analytics_workspace_id
            listOfLocations                                               = var.allowed_locations
          }

          CU-Deploy-Activity-Logs = {
            effect               = "DeployIfNotExists"
            actionGroupName      = "secopsag"
            actionGroupShortName = "secopsag"
            emailAddress         = "pauyu@microsoft.com"
            activityLogAlertName = "NSGDeleted"
            operationName        = "Microsoft.Network/networkSecurityGroups/delete"
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
            logAnalyticsWorkspaceIDForVMAgents         = var.secops_log_analytics_workspace_id
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
            logAnalyticsWorkspaceId-f47b5582-33ec-4c5c-87c0-b010a6b2e917 = var.secops_log_analytics_workspace_id
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

        Deploy-AzActivity-Log = {
          logAnalytics = var.secops_log_analytics_workspace_resource_id
        }

        Deploy-LX-Arc-Monitoring = {
          logAnalytics = var.secops_log_analytics_workspace_resource_id
        }

        Deploy-Resource-Diag = {
          logAnalytics = var.secops_log_analytics_workspace_resource_id
        }

        Deploy-VM-Monitoring = {
          logAnalytics_1 = var.secops_log_analytics_workspace_resource_id
        }

        Deploy-VMSS-Monitoring = {
          logAnalytics_1 = var.secops_log_analytics_workspace_resource_id
        }

        Deploy-WS-Arc-Monitoring = {
          logAnalytics = var.secops_log_analytics_workspace_resource_id
        }

        CU-Audit-CIS = {
          listOfRegionsWhereNetworkWatcherShouldBeEnabled = var.allowed_locations
          listOfApprovedVMExtensions                      = var.allowed_vm_extensions
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
    landing-zones  = []
    platform       = var.platform_subs
    connectivity   = var.connectivity_subs
    management     = var.management_subs
    identity       = var.identity_subs
  }
}

# TODO: Grant all managed identities for CU-Deploy-Diag-* policies Log Analytics Contributor access to centralized Log Analytics Workspace

# module "budgets" {
#   source          = "./modules/budgets"
#   count           = length(var.connectivity_subs)
#   subscription_id = var.connectivity_subs[count.index]
# }