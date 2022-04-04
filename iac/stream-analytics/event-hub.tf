data "azurerm_storage_account" "adls" {
  name                = "cryptoanalyticslake"
  resource_group_name = "adls2-demo-eastus2"
}

data "azurerm_eventhub_namespace" "ehns" {
  name                = "ehns-quote-streams"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_eventhub" "eh" {
  name                = "eh-crypto-stream"
  namespace_name      = data.azurerm_eventhub_namespace.ehns.name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_eventhub_consumer_group" "stream_analytics_consumer" {
  name                = "stream-analytics-consumer"
  namespace_name      = data.azurerm_eventhub_namespace.ehns.name
  eventhub_name       = data.azurerm_eventhub.eh.name
  resource_group_name = data.azurerm_resource_group.rg.name
}