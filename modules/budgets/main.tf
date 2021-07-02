resource "random_integer" "budget" {
  min = 1
  max = 2147483647
  keepers = {
    tags = jsonencode(var.tags)
  }
}

resource "azurerm_subscription_template_deployment" "budget" {
  name          = "${var.subscription_id}-${random_integer.budget.result}"
  location      = var.location
  template_body = file("template.json")

  parameters_body = jsonencode({
    "budgetName" : {
      "value" : var.budgetName
    },
    "amount" : {
      "value" : var.amount
    },
    "timeGrain" : {
      "value" : var.timeGrain
    },
    "startDate" : {
      "value" : var.startDate
    },
    "endDate" : {
      "value" : var.endDate
    },
    "firstThreshold" : {
      "value" : var.firstThreshold
    },
    "secondThreshold" : {
      "value" : var.secondThreshold
    },
    "contactEmails" : {
      "value" : var.contactEmails
    },
    "contactRoles" : {
      "value" : var.contactRoles
    },
    "contactGroups" : {
      "value" : var.contactGroups
    },
    "resourceGroupFilterValues" : {
      "value" : var.resourceGroupFilterValues
    },
    "meterCategoryFilterValues" : {
      "value" : var.meterCategoryFilterValues
    }
  })
}