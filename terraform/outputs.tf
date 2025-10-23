output "app_url" {
  description = "應用程式的 URL"
  value       = "https://${azurerm_container_app.app.latest_revision_fqdn}"
}

output "mysql_server_fqdn" {
  description = "MySQL 伺服器的 FQDN"
  value       = azurerm_mysql_flexible_server.mysql.fqdn
}

output "container_registry_login_server" {
  description = "Container Registry 登入伺服器"
  value       = azurerm_container_registry.acr.login_server
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.kv.vault_uri
}