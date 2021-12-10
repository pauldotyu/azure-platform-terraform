variable "subscription_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "root_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "root_name" {
  type        = string
  description = "(optional) describe your variable"
}

variable "default_location" {
  type        = string
  description = "(optional) describe your variable"
}

variable "secops_log_analytics_workspace_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "secops_log_analytics_workspace_resource_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "secops_storage_account_resource_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "secops_nsg_rg_name" {
  type        = string
  description = "(optional) describe your variable"
}

variable "secops_nsg_storage_prefix" {
  type        = string
  description = "(optional) describe your variable"
}

variable "allowed_locations" {
  type        = list(string)
  description = "(optional) describe your variable"
}

variable "allowed_resources" {
  type        = list(string)
  description = "(optional) describe your variable"
}

variable "allowed_vm_extensions" {
  type        = list(string)
  description = "(optional) describe your variable"
}

variable "connectivity_subs" {
  type        = list(string)
  description = "(optional) describe your variable"
}

variable "sde_hipaa_subs" {
  type        = list(string)
  description = "(optional) describe your variable"
}

variable "sde_nist_subs" {
  type        = list(string)
  description = "(optional) describe your variable"
}

variable "sandbox_subs" {
  type        = list(string)
  description = "(optional) describe your variable"
}

variable "platform_subs" {
  type        = list(string)
  description = "(optional) describe your variable"
}

variable "management_subs" {
  type        = list(string)
  description = "(optional) describe your variable"
}

variable "identity_subs" {
  type        = list(string)
  description = "(optional) describe your variable"
}