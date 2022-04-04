data "azurerm_sql_server" "sql" {
  name                         = "sql-alert-meta"
  resource_group_name          = data.azurerm_resource_group.rg.name
}

data "azurerm_sql_database" "db" {
  name                = "TradeAlerts"
  resource_group_name = data.azurerm_resource_group.rg.name
}

