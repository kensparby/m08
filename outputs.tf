// output the web link to the static website
output "web_link" {
  value = azurerm_storage_account.sa.primary_web_endpoint
}

output "primary_web_output" {
  value = azurerm_storage_account.sa.primary_web_endpoint
}