variable "subscription_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "tags" {
  type        = map(any)
  description = "(optional) describe your variable"
  default = {
    environment = "dev"
  }
}

variable "location" {
  type        = string
  description = "(optional) describe your variable"
}

variable "budgetName" {
  type        = string
  description = "(optional) describe your variable"
  default     = "GEN-UNIQUE"
}

variable "amount" {
  type        = string
  description = "(optional) describe your variable"
  default     = "1000"
}

variable "timeGrain" {
  type        = string
  description = "(optional) describe your variable"
  default     = "Monthly"
}

variable "startDate" {
  type        = string
  description = "(optional) describe your variable"
  default     = "2020-07-01"
}

variable "endDate" {
  type        = string
  description = "(optional) describe your variable"
  default     = "2030-12-31"
}

variable "firstThreshold" {
  type        = string
  description = "(optional) describe your variable"
  default     = "80"
}

variable "secondThreshold" {
  type        = string
  description = "(optional) describe your variable"
  default     = "100"
}

variable "contactEmails" {
  type        = list(string)
  description = "(optional) describe your variable"
  default = [
    "abc@contoso.com",
    "xyz@contoso.com"
  ]
}

variable "contactRoles" {
  type        = list(string)
  description = "(optional) describe your variable"
  default = [
    "Contributor",
    "Reader"
  ]
}

variable "contactGroups" {
  type        = list(string)
  description = "(optional) describe your variable"
  default     = []
}

variable "resourceGroupFilterValues" {
  type        = list(string)
  description = "(optional) describe your variable"
  default = [
    "ResourceGroup1",
    "ResourceGroup2"
  ]
}

variable "meterCategoryFilterValues" {
  type        = list(string)
  description = "(optional) describe your variable"
  default = [
    "MeterCategory1"
  ]
}