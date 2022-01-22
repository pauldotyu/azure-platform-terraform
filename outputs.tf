output "available_subscriptions" {
  value = data.azurerm_subscriptions.available.subscriptions
}