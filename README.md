# azure-platform-terraform

The intent of this repo is to build foundational Azure Landing Zone components using the [Azure/caf-enterprise-scale](https://registry.terraform.io/modules/Azure/caf-enterprise-scale/azurerm/latest) Terraform module which includes the following resources:

- Customized management group structure
- Custom policies and assignments at root and other MG scopes under the "Landing zones" MG
  - Customizations can be found in the lib/\* directories.
- Centralized log analytics workspace for SecOps

## Prerequisites

You must have access to an Azure subscription with the Owner role assigned to the [default management group](https://docs.microsoft.com/en-us/azure/governance/management-groups/how-to/protect-resource-hierarchy#setting---default-management-group). See this [doc](https://docs.microsoft.com/en-us/azure/governance/management-groups/create-management-group-portal#prerequisites) for more info on permisions required to work with Azure Management Groups or this [doc](https://docs.microsoft.com/en-us/azure/role-based-access-control/elevate-access-global-admin) to elevate access to manage all Azure subscriptions and management groups..

This repo uses [Terraform Cloud](https://www.terraform.io/cloud-docs) for remote storage and remote runs. If you are using some other remote state solution, please update `backend.tf` accordingly.

To initialize your backend, you'll need to supply additional backend configs. This repo uses a partial backend configuration file named `config.remote.tfbackend` which is kept as a secret in the github repo. The config file looks like this:

```terraform
workspaces { name = "<MY_TF_WORKSPACE_NAME>" }
hostname     = "app.terraform.io"
organization = "<MY_TF_ORGANIZATION_NAME>"
```

To initialize the backend, you can pass in the \*.tfbackend file at runtime like this;

```sh
terraform init --backend-config=config.remote.tfbackend
```

## Automation

This repo uses GitHub Actions to deploy and destroy resources. To deploy resources, create a pull request and label it with `deploy`. This will trigger a `terraform apply` command. To destroy resources, create a pull request and label it with `destroy`. This will trigger a `terrafrom destroy` command.

## Deploying your Landing Zones

The intent of this repo is to demonstrate how to customize the deployment to suit your organizational needs. 

### Directory Structure

In order to override some settings that is available out-of-the-box, I've duplicated a few files and placed in my own `lib` directory. You'll find there is a `lib` directory in the root of this repo with the following directory structure:

```text
lib
├── archetype_definitions
│   ├── archetype_definition_cu_connectivity.json
│   ├── archetype_definition_cu_identity.json
│   ├── archetype_definition_cu_landing_zones.json
│   ├── archetype_definition_cu_management.json
│   ├── archetype_definition_cu_restricted.json
│   ├── archetype_definition_cu_root.json
│   ├── archetype_definition_cu_sde.json
│   ├── archetype_definition_cu_sde_cmmc.json
│   ├── archetype_definition_cu_sde_hipaa.json
│   └── archetype_definition_cu_sde_nist.json
├── policy_assignments
│   ├── policy_assignment_cu_audit_aks_authorized_ips.json
│   ├── policy_assignment_cu_audit_aks_baseline.json
│   ├── policy_assignment_cu_audit_aks_container_images.json
│   ├── policy_assignment_cu_audit_aks_defender.json
│   ├── policy_assignment_cu_audit_aks_https.json
│   ├── policy_assignment_cu_audit_aks_internal_load_balancer.json
│   ├── policy_assignment_cu_audit_aks_policy_addon.json
│   ├── policy_assignment_cu_audit_aks_rbac.json
│   ├── policy_assignment_cu_audit_aks_version.json
│   ├── policy_assignment_cu_audit_aks_volume_types.json
│   ├── policy_assignment_cu_audit_cis.json
│   ├── policy_assignment_cu_audit_cmmc.json
│   ├── policy_assignment_cu_audit_hipaa.json
│   ├── policy_assignment_cu_audit_nist_800_171_r2.json
│   ├── policy_assignment_cu_audit_nist_800_53_r5.json
│   ├── policy_assignment_cu_audit_resource_groups_without_required_tags.tmpl.json
│   ├── policy_assignment_cu_audit_resources_without_required_tags.tmpl.json
│   ├── policy_assignment_cu_audit_storage_with_public_blob_access.json
│   ├── policy_assignment_cu_audit_windows_license.json
│   ├── policy_assignment_cu_deny_resources.json
│   ├── policy_assignment_cu_deploy_activity_log_alerts.json
│   ├── policy_assignment_cu_deploy_microsoft_defenders.json
│   ├── policy_assignment_cu_deploy_vm_dependencyagent.json
│   └── policy_assignment_cu_deploy_vm_qualys.json
├── policy_definitions
│   ├── policy_definition_cu_audit_storage_with_public_blob_access.json
│   ├── policy_definition_cu_audit_windows_server_missing_byol.json
│   ├── policy_definition_cu_deploy_activity_log_alerts.json
│   ├── policy_definition_cu_resource_groups_without_required_tags.json
│   └── policy_definition_cu_resources_without_required_tags.json
├── policy_set_definitions
│   └── policy_set_definition_cu_deploy_defenders.json
└── role_definitions
    ├── role_definition_cu_application_owner.json
    ├── role_definition_cu_avd_autoscale.json
    ├── role_definition_cu_network_operations.json
    ├── role_definition_cu_security_operations.json
    └── role_definition_cu_subscription_owner.json
```

The subdirectory structure above has the same structure as the module's [`lib`](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/tree/main/modules/archetypes/lib) directory. However, the files are custom to this deployment.

Below is a breakdown of how each subdirectory is used:

> Note how each of the files will include the `root_id` in the naming convention to help identify which items are custom to this repo.

**Management Groups**

To override or add any management groups, create a new file with the naming convention of `archetype_definition_${root_id}_${management_group}.json` and drop it into the `archetype_definitions` directory.

**Policy Definitions**

To add any new custom policies, create a new file with the naming convention of `policy_definition_${root_id}_${policy_name}.json` and drop it into the `policy_definitions` directory.

**Policy Set (Initiative) Definitions**

To add any new custom policies sets (also known as initiatives in the Azure Portal), create a new file with the naming convention of `policy_set_definition_${root_id}_${policy_set_name}.json` and drop it into the `policy_definitions` directory.

**Policy Assignments**

To add any new policy assignments, create a new file with the naming convention of `policy_assignment_${root_id}_${policy_assignment_name}.json` and drop it into the `policy_assignments` directory.

**Role Definitions**

To add any new role definitions, create a new file with the naming convention of `role_definition_${root_id}_${role_name}.json` and drop it into the `policy_assignments` directory.

### Overriding Default Management Groups

If you deploy the module without any customization as outlined in this [doc](https://registry.terraform.io/modules/Azure/caf-enterprise-scale/azurerm/latest#usage) you will get the basic management group hierarchy of:

```text
Tenant root group
├── Contoso
│   ├── Platform
|   |   ├── Identity
|   |   ├── Management
|   |   ├── Connectivity
│   ├── Landing zones
|   |   ├── SAP
|   |   ├── Corp
|   |   ├── Online
│   ├── Decommissioned
│   ├── Sandbox
```

The definitions of each mangement group can be found here: https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/tree/main/modules/archetypes/lib/archetype_definitions

In order to override the configurations, you should copy files from the source repo and drop them into your `lib/archetype_definitions` directory. You can refer to `lib/archetype_definitions/archetype_definition_cu_root.json` as an example of how I overridden the [root definition file found in the source repo](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/blob/main/modules/archetypes/lib/archetype_definitions/archetype_definition_es_root.tmpl.json).

With your customizations in place, you'll need to make edits in the `main.tf`.

First add a setting in the `module.enterprise_scale` resource to point to your custom `lib` directory

```terraform
module "enterprise_scale" {
  ...
  library_path              = "${path.root}/lib" 
  ...
}
```

Next, you need to add a `archetype_config_overrides` block in the `module.enterprise_scale` resource to override specific management groups.

> Note that each of the base management groups use the following identifiers. You will need to refer to these in your override configs.
> - `root`
> - `management`
> - `landing-zones`
> - `identity`
> - `connectivity`

Here is an example of how the root management group with display name of "Contoso Univeristy" and identifer of "cu" has been configured.

```terraform
module "enterprise_scale" {
  ...
  archetype_config_overrides = {
    root = {
      archetype_id = "cu_root"
      parameters = {
        ...
      }
      access_control = {}
    }
  }
  ...
}
```

In the example above, the `archetype_id = "cu_root"` tells the module that the configuration for `root` should use the `archetype_definition` object where the identifer is `cu_root`. This is defined in the file `lib/archetype_definitions/archetype_definition_cu_root.json`. Also, in my configruation file, I've added my own custom objects in the `policy_assignments`, `policy_definitions`, and `role_definitions` arrays. 

When assigning policy to a management group, most often the policy assignment will require parameter values. This is done by filling in the `parameters` block in the management group overide section. 
This requires a bit of understanding on how Azure Policy assignments work. For each policy assignment, understand what parameter it is expecting and pass them in accordingly. Below is an example on how I passed in parameter values to some of the policy assignments for my `cu_root` management group.

> It is recommended you go through this [tutorial](https://docs.microsoft.com/en-us/azure/governance/policy/assign-policy-portal) to understand how policy assignments work in the Azure Portal.

```terraform
module "enterprise_scale" {
  ...
  archetype_config_overrides = {
    root = {
      ...
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
      ...
    }
  }
  ...
}
```

### Adding Custom Management Groups

You can also add new management groups or completely override the structure altogether.

In order to add custom management groups, you need to use the `custom_landing_zones` block within the `module.enterprise_scale` resource. 

Below is an example of how to add a "Secure Data Enclave" management group under "Landing Zones" and nest in a "HITRUST/HIPAA" management group under "Secure Data Enclave".

```terraform
module "enterprise_scale" {
  ...
  custom_landing_zones = {
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
  }
```

You'll need to create a new map object inside the `custom_landing_zones` object. Here, I've created two new maps with the id `cu-sde` and `cu-sde-hipaa`. Within each map object, you can set the display name and the `parent_management_group_id`. This controls where the management group will be placed within the hiearchy. Note how `cu-sde` is nested under `cu-landing-zones` and the `cu-sde-hipaa` management group is nested under `cu-sde`.

Within each block you can then point to the `archetype_defintion_*` file using the `archetype_config` object.

```terraform
module "enterprise_scale" {
  ...
  custom_landing_zones = {
    cu-sde = {
      ...
      archetype_config = {
        archetype_id = "cu_sde"
        parameters = {
        }
        ...
      }
    }

    cu-sde-hipaa = {
      ...
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
        ...
      }
    }
  }
```

Similar to the way we overridden our base management groups, we point to objects using their map identifier; in this case `cu_sde` and `cu_sde_hipaa` respectively and can pass in any policy assignment parameters into the config.

### Adding Custom Policies

You can also add custom policies or policy sets to your deployment. 

You will need to first define the Azure Policy or Azure Policy set using ARM templates and place the files in the `lib/policy_definitions` or `lib/policy_set_definitions` directories (depending on which type of policy you are adding).

> Refer to the following docs for more info on authoring policies:
> - https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/create-custom-policy-definition
> - https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/policydefinitions?tabs=bicep

Once your policies have been defined via ARM templates, you need to reference the policy name within your management group definition file. Remember, these files live in the `lib/archetype_definitions` directory.

To define a policy, you need to include it in the appropriate management group definition file as this will drive the scope in which the policy is defined at.

Here is an example of custom resources being defined in the `cu_root` management group:

```terraform
{
  "cu_root": {
    "policy_assignments": [
      ...
      "CU-Audit-Public-Blobs",
      "CU-Audit-AKS-Auth-IPs",
      "CU-Audit-AKS-Baseline",
      "CU-Audit-AKS-Defender",
      "CU-Audit-AKS-Images",
      "CU-Audit-AKS-Internal-LB",
      "CU-Audit-AKS-HTTPS",
      "CU-Audit-AKS-Policy",
      "CU-Audit-AKS-RBAC",
      "CU-Audit-AKS-Version",
      "CU-Audit-AKS-Volume-Type"
    ],
    "policy_definitions": [
      ...
      "CU-Audit-Storage-With-Public-Blob-Access",
      "CU-Audit-Windows-Server-License",
      "CU-Audit-Resource-Groups-Without-Required-Tags",
      "CU-Audit-Resources-Without-Required-Tags"
    ],
    "policy_set_definitions": [
      ...
    ],
    "role_definitions": [
      "CU-AVD-Autoscale"
    ],
    "archetype_config": {
      "parameters": {},
      "access_control": {}
    }
  }
}
```

Defining at this scope, will allow these objects to be used across your entire "Azure Landing Zone" architecture.

> If you attempt to assign a policy and forget to include the policy defintion, an error will result at runtime.

With regard to `policy_assignments`, they are simply Azure ARM templates which can assign either built-in or custom policies. In the example above, the majority of the policy assignments are for built-in policies and do not require their existence in the `policy_definitions` block. See this [doc](https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/policyassignments?tabs=bicep) for mor info on policy assignments.

## Running the Project

If you are running this project on Terraform Cloud and using their remote infrastructure, make sure you've added the `TFE_PARALLELISM` environment variable and set it to 256.

To deploy this project, make sure you have initizlized the terraform directory (see above), then run the following:

```bash
terraform apply
```

If you are running this project locally on your machine, make sure to apply with the `-paralelism` flag set to 256. This will allow terraform to deploy resources with up to 256 concurrent threads and ultimately deploy the architecture quicker. You can run the code locally using this command.

```bash
terraform apply -paralelism=256
```

## Handling Module Upgrades

As the [terraform-azurerm-caf-enterprise-scale](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/releases) is updated, you will need to manually increment the version number in `main.tf`.

Here are the steps, I take to update the module.

Go to https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/releases and determine the latest version. At the time of this writing, the latest verions is v2.1.2 and I am currently running v2.0.2.

Open the `main.tf` file and update the `version` in the `enterprise_scale` module definition.

The beginning of the module should now look like this:

```terraform
module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "2.1.2" # <-- Update this value
  ...
```

Since I modified my `lib` directory and overwritten the `root` module with my own implementation, I'll need to head out to the repo and make sure I am also updating the base definitions as things may have changed with the latest release.

In the source repo, you can dig into the `lib` directory and and drill in until you get to the [archetype_definition_es_root.tmpl.json](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/blob/main/modules/archetypes/lib/archetype_definitions/archetype_definition_es_root.tmpl.json) file. It is in the `modules/archetypes/lib/archetype_definitions` directory.

Open the [file](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/blob/main/modules/archetypes/lib/archetype_definitions/archetype_definition_es_root.tmpl.json) and copy the contents inside the `policy_assignments` array to your clipboard.

In your local repo, open the file `/lib/archetype_definitions/archetype_definition_cu_root.json`. Paste in the contents in your clipboard into the `policy_assignments` array, overwriting everything except for the policy assignments that start with `CU-`. These are our custom policy assignments so we don't want to overrite these.

> Most of the time, this will not change between minor version updates. You can visually compare your **root** file with the repos **root** and determine if you need to copy/paste at all. 

Do the same for the `policy_definitions` array and the `policy_set_definitions` array, but be very careful not to remove any of your custom policy definitions and policy set definitions. This is the reason why I prefixed everything with `CU-` to be able to quickly identify which items I customized.

> If you miss any of the base module's policy defintions or policy set definitions you will run into errors during runtime.

We are now ready to upgrade the module.

In your terminal, run the following:

```terraform
terraform init --backend-config=config.remote.tfbackend -upgrade
terraform apply
```

Pay special attention to the terraform output before proceeding. Generally, you will see a lot of role assignment deletions and creations, however, these will not be a problem. You should be on the lookout for other resource deletions. When ready, type `yes` to run the deployment.
