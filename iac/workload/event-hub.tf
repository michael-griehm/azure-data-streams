data "azurerm_storage_account" "adls" {
  name                = "cryptoanalyticslake"
  resource_group_name = "adls2-demo-eastus2"
}

resource "azurerm_eventhub_namespace" "ehns" {
  name                = "ehns-quote-streams"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1
  zone_redundant      = true
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  network_rulesets {
    default_action                 = "Allow"
    trusted_service_access_enabled = true
  }
}

resource "azurerm_eventhub" "eh" {
  name                = "eh-crypto-stream"
  namespace_name      = azurerm_eventhub_namespace.ehns.name
  resource_group_name = data.azurerm_resource_group.rg.name
  partition_count     = 20
  message_retention   = 1

  capture_description {
    enabled = true
    encoding = "Avro"
    interval_in_seconds = 60
    size_limit_in_bytes = 10485760
    skip_empty_archives = false

    destination {
      name = "EventHubArchive.AzureBlockBlob"
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
      blob_container_name = "crypto-quotes"
      storage_account_id = data.azurerm_storage_account.adls.id
    }
  } 
}

resource "azurerm_eventhub_authorization_rule" "producer" {
  name                = "sap-function-stream-producer"
  namespace_name      = azurerm_eventhub_namespace.ehns.name
  eventhub_name       = azurerm_eventhub.eh.name
  resource_group_name = data.azurerm_resource_group.rg.name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_eventhub_authorization_rule" "consumer" {
  name                = "sap-function-stream-consumer"
  namespace_name      = azurerm_eventhub_namespace.ehns.name
  eventhub_name       = azurerm_eventhub.eh.name
  resource_group_name = data.azurerm_resource_group.rg.name
  listen              = true
  send                = false
  manage              = false
}