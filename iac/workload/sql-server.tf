variable "sql_admin_principal_name" {
  type        = string
  sensitive   = true
  description = "The user principal name of the admin for the app."
  default     = "mikeg@ish-star.com"
}

variable "sql_admin_login" {
  type        = string
  sensitive   = true
  description = "The username of the system admin for the SQL Server."
}

data "azuread_user" "sql_admin_user_account" {
  user_principal_name = var.sql_admin_principal_name
}

resource "random_password" "password" {
  length      = 24
  min_lower   = 3
  min_upper   = 3
  min_special = 3
  min_numeric = 3
}

data "azurerm_key_vault" "sql_vault" {
  resource_group_name = data.azurerm_resource_group.rg.name
  name                = "sqlalertmeta"
}

resource "azurerm_key_vault_secret" "stored_secret" {
  name         = var.sql_admin_login
  value        = random_password.password.result
  key_vault_id = data.azurerm_key_vault.sql_vault.id
}

resource "azurerm_sql_server" "sql" {
  name                         = "sql-alert-meta"
  resource_group_name          = data.azurerm_resource_group.rg.name
  location                     = data.azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = random_password.password.result
  tags                         = var.tags

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_sql_firewall_rule" "home_firewall_rule" {
  name                = "HomeIP"
  resource_group_name = data.azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sql.name
  start_ip_address    = "24.31.171.98"
  end_ip_address      = "24.31.171.98"

  depends_on = [
    azurerm_sql_server.sql
  ]
}

resource "azurerm_sql_active_directory_administrator" "aad" {
  server_name         = azurerm_sql_server.sql.name
  resource_group_name = data.azurerm_resource_group.rg.name
  login               = "sql-aad-admin"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azuread_user.sql_admin_user_account.object_id

  depends_on = [
    azurerm_sql_firewall_rule.home_firewall_rule
  ]
}

resource "azurerm_sql_database" "db" {
  name                = "TradeAlerts"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql.name
  tags                = var.tags
  create_mode         = "Default"
  edition             = "Free"

  depends_on = [
    azurerm_sql_active_directory_administrator.aad
  ]
}

resource "azurerm_key_vault_secret" "db_connection_string_secret" {
  name         = azurerm_sql_database.db.name
  value        = "Server=tcp:${azurerm_sql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.db.name};Persist Security Info=False;User ID=${azurerm_sql_server.sql.administrator_login};Password=${azurerm_sql_server.sql.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = data.azurerm_key_vault.sql_vault.id

  depends_on = [
    azurerm_sql_database.db
  ]
}
