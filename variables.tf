variable "root_id" {
  type        = string
  description = "This is the 2-3 character identifier which will be used in naming your management group ids. This value cannot be modified once deployed."
}

variable "root_name" {
  type        = string
  description = "This is the display name for your root management group. This value can be modified after deployment."
}

variable "default_location" {
  type        = string
  description = "This is the default Azure region where resoruces related to management groups, policy definitions, and policy assignments will be deployed into."
}

variable "allowed_locations" {
  type        = list(string)
  description = "(Optional) This is a list of approved locations for resource deployments which will then be passed into a policy assignment parameter."
  default = [
    "centralus",
    "eastus",
    "eastus2",
    "northcentralus",
    "southcentralus",
    "westcentralus",
    "westus",
    "westus2",
    "global"
  ]
}

variable "allowed_resources" {
  type        = list(string)
  description = "(Optional) This is a list of approved resources for deployment which will then be passed into a policy assignment parameter."
  default = [
    "Microsoft.Compute/availabilitySets",
    "Microsoft.Compute/cloudServices",
    "Microsoft.Compute/diskAccesses",
    "Microsoft.Compute/diskAccesses/privateEndpointConnections",
    "Microsoft.Compute/diskEncryptionSets",
    "Microsoft.Compute/disks",
    "Microsoft.Compute/galleries",
    "Microsoft.Compute/galleries/applications",
    "Microsoft.Compute/galleries/applications/versions",
    "Microsoft.Compute/galleries/images",
    "Microsoft.Compute/galleries/images/versions",
    "Microsoft.Compute/hostGroups",
    "Microsoft.Compute/hostGroups/hosts",
    "Microsoft.Compute/images",
    "Microsoft.Compute/proximityPlacementGroups",
    "Microsoft.Compute/snapshots",
    "Microsoft.Compute/sshPublicKeys",
    "Microsoft.Compute/virtualMachines",
    "Microsoft.Compute/virtualMachines/extensions",
    "Microsoft.Compute/virtualMachines/runCommands",
    "Microsoft.Compute/virtualMachineScaleSets",
    "Microsoft.Compute/virtualMachineScaleSets/extensions",
    "Microsoft.Compute/virtualMachineScaleSets/virtualmachines",
    "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/extensions",
    "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/runCommands",
    "Microsoft.KeyVault/vaults",
    "Microsoft.KeyVault/vaults/accessPolicies",
    "Microsoft.KeyVault/vaults/keys",
    "Microsoft.KeyVault/vaults/privateEndpointConnections",
    "Microsoft.KeyVault/vaults/vaults/secrets",
    "Microsoft.Network/applicationGateways",
    "Microsoft.Network/applicationGateways/privateEndpointConnections",
    "Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies",
    "Microsoft.Network/applicationSecurityGroups",
    "Microsoft.Network/azureFirewalls",
    "Microsoft.Network/bastionHosts",
    "Microsoft.Network/connections",
    "Microsoft.Network/customIpPrefixes",
    "Microsoft.Network/ddosCustomPolicies",
    "Microsoft.Network/ddosProtectionPlans",
    "Microsoft.Network/dscpConfigurations",
    "Microsoft.Network/expressRouteCircuits",
    "Microsoft.Network/expressRouteCircuits/authorizations",
    "Microsoft.Network/expressRouteCircuits/peerings",
    "Microsoft.Network/expressRouteCircuits/peerings/connections",
    "Microsoft.Network/expressRouteCrossConnections",
    "Microsoft.Network/expressRouteCrossConnections/peerings",
    "Microsoft.Network/expressRouteGateways",
    "Microsoft.Network/expressRouteGateways/expressRouteConnections",
    "Microsoft.Network/ExpressRoutePorts",
    "Microsoft.Network/firewallPolicies",
    "Microsoft.Network/firewallPolicies/ruleCollectionGroups",
    "Microsoft.Network/firewallPolicies/ruleGroups",
    "Microsoft.Network/IpAllocations",
    "Microsoft.Network/ipGroups",
    "Microsoft.Network/loadBalancers",
    "Microsoft.Network/loadBalancers/backendAddressPools",
    "Microsoft.Network/loadBalancers/inboundNatRules",
    "Microsoft.Network/localNetworkGateways",
    "Microsoft.Network/natGateways",
    "Microsoft.Network/networkInterfaces",
    "Microsoft.Network/networkInterfaces/tapConfigurations",
    "Microsoft.Network/networkProfiles",
    "Microsoft.Network/networkSecurityGroups",
    "Microsoft.Network/networkSecurityGroups/securityRules",
    "Microsoft.Network/networkVirtualAppliances",
    "Microsoft.Network/networkVirtualAppliances/inboundSecurityRules",
    "Microsoft.Network/networkVirtualAppliances/virtualApplianceSites",
    "Microsoft.Network/networkWatchers",
    "Microsoft.Network/networkWatchers/connectionMonitors",
    "Microsoft.Network/networkWatchers/flowLogs",
    "Microsoft.Network/networkWatchers/packetCaptures",
    "Microsoft.Network/p2svpnGateways",
    "Microsoft.Network/privateEndpoints",
    "Microsoft.Network/privateEndpoints/privateDnsZoneGroups",
    "Microsoft.Network/privateLinkServices",
    "Microsoft.Network/privateLinkServices/privateEndpointConnections",
    "Microsoft.Network/publicIPAddresses",
    "Microsoft.Network/publicIPPrefixes",
    "Microsoft.Network/routeFilters",
    "Microsoft.Network/routeFilters/routeFilterRules",
    "Microsoft.Network/routeTables",
    "Microsoft.Network/routeTables/routes",
    "Microsoft.Network/securityPartnerProviders",
    "Microsoft.Network/serviceEndpointPolicies",
    "Microsoft.Network/serviceEndpointPolicies/serviceEndpointPolicyDefinitions",
    "Microsoft.Network/virtualHubs",
    "Microsoft.Network/virtualHubs/bgpConnections",
    "Microsoft.Network/virtualHubs/hubRouteTables",
    "Microsoft.Network/virtualHubs/hubVirtualNetworkConnections",
    "Microsoft.Network/virtualHubs/ipConfigurations",
    "Microsoft.Network/virtualHubs/routeTables",
    "Microsoft.Network/virtualNetworkGateways",
    "Microsoft.Network/virtualNetworks",
    "Microsoft.Network/virtualNetworks/subnets",
    "Microsoft.Network/virtualNetworks/virtualNetworkPeerings",
    "Microsoft.Network/virtualNetworkTaps",
    "Microsoft.Network/virtualRouters",
    "Microsoft.Network/virtualRouters/peerings",
    "Microsoft.Network/virtualWans",
    "Microsoft.Network/vpnGateways",
    "Microsoft.Network/vpnGateways/vpnConnections",
    "Microsoft.Network/vpnServerConfigurations",
    "Microsoft.Network/vpnSites",
    "Microsoft.SqlVirtualMachine/sqlVirtualMachineGroups",
    "Microsoft.SqlVirtualMachine/sqlVirtualMachineGroups/availabilityGroupListeners",
    "Microsoft.SqlVirtualMachine/sqlVirtualMachines",
    "Microsoft.Storage/storageAccounts",
    "Microsoft.Storage/storageAccounts/blobServices",
    "Microsoft.Storage/storageAccounts/blobServices/containers",
    "Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies",
    "Microsoft.Storage/storageAccounts/encryptionScopes",
    "Microsoft.Storage/storageAccounts/fileServices",
    "Microsoft.Storage/storageAccounts/fileServices/shares",
    "Microsoft.Storage/storageAccounts/managementPolicies",
    "Microsoft.Storage/storageAccounts/objectReplicationPolicies",
    "Microsoft.Storage/storageAccounts/privateEndpointConnections",
    "Microsoft.Storage/storageAccounts/queueServices",
    "Microsoft.Storage/storageAccounts/queueServices/queues",
    "Microsoft.Storage/storageAccounts/tableServices",
    "Microsoft.Storage/storageAccounts/tableServices/tables"
  ]
}

variable "allowed_vm_extensions" {
  type        = list(string)
  description = "(Optional) This is a list of approved VM extensions which will then be passed into a policy assignment parameter."
  default = [
    "AzureDiskEncryption",
    "AzureDiskEncryptionForLinux",
    "DependencyAgentWindows",
    "DependencyAgentLinux",
    "IaaSAntimalware",
    "IaaSDiagnostics",
    "LinuxDiagnostic",
    "MicrosoftMonitoringAgent",
    "NetworkWatcherAgentLinux",
    "NetworkWatcherAgentWindows",
    "OmsAgentForLinux",
    "VMSnapshot",
    "VMSnapshotLinux",
    "LinuxAgent.AzureSecurityCenter",
    "JsonADDomainExtension",
    "MDE.Windows",
    "WindowsAgent.AzureSecurityCenter",
    "ConfigurationforWindows",
    "CustomScriptExtension"
  ]
}

variable "connectivity_subs" {
  type        = list(string)
  description = "(Optional) List of subscriptions to be nested under the Connectivity management group"
}

variable "landing_zone_subs" {
  type        = list(string)
  description = "(Optional) List of subscriptions to be nested under the Connectivity management group"
}

variable "sde_hipaa_subs" {
  type        = list(string)
  description = "(Optional) List of subscriptions to be nested under the Connectivity management group"
}

variable "sde_nist_subs" {
  type        = list(string)
  description = "(Optional) List of subscriptions to be nested under the Connectivity management group"
}

variable "sandbox_subs" {
  type        = list(string)
  description = "(Optional) List of subscriptions to be nested under the Connectivity management group"
}

variable "platform_subs" {
  type        = list(string)
  description = "(Optional) List of subscriptions to be nested under the Connectivity management group"
}

variable "management_subs" {
  type        = list(string)
  description = "(Optional) List of subscriptions to be nested under the Connectivity management group"
}

variable "identity_subs" {
  type        = list(string)
  description = "(Optional) List of subscriptions to be nested under the Connectivity management group"
}

variable "restricted_subs" {
  type        = list(string)
  description = "(Optional) List of subscriptions to be nested under the Connectivity management group"
}

variable "tags" {
  type        = map(any)
  description = "Values to be added to the tags of the resources"
}

# variable "azure_defender_subscriptions" {
#   type        = list(string)
#   description = "List of subscriptions to be added to Azure Defender"
# }

variable "azure_defender_contact" {
  type = object({
    email = string
    phone = string
  })
  description = "Azure Defender contact information"
}