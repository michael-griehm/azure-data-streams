resource "azurerm_stream_analytics_cluster" "cluster" {
  name                = "realtime-analytics-cluster"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  streaming_capacity  = 36
  tags                = var.tags
}

resource "azurerm_stream_analytics_job" "crypto_high_alert_job" {
  name                                     = "crypto-high-alert-job"
  resource_group_name                      = data.azurerm_resource_group.rg.name
  location                                 = data.azurerm_resource_group.rg.location
  compatibility_level                      = "1.2"
  data_locale                              = "en-US"
  events_late_arrival_max_delay_in_seconds = 60
  events_out_of_order_max_delay_in_seconds = 50
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Drop"
  streaming_units                          = 1
  tags                                     = var.tags

  transformation_query = <<QUERY
    SELECT
    s.[Symbol], r.[UserId], Max(s.[Price]) AS MaxPrice, Min(s.[Price]) AS MinPrice, System.Timestamp() AS WindowEndTime, COUNT(*) AS Cnt
    INTO
        [crypto-price-alert-output]
    FROM
        [crypto-stream-input] s
    JOIN
        [crypto-alert-rules] r ON s.[Symbol] = r.[Symbol] AND r.[High] > s.[Price] 
    GROUP BY s.Symbol, r.[UserId], TumblingWindow(minute, 5)
QUERY

}

resource "azurerm_stream_analytics_stream_input_eventhub" "crypto_stream_input" {
  name                         = "crypto-stream-input"
  stream_analytics_job_name    = azurerm_stream_analytics_job.crypto_high_alert_job.name
  resource_group_name          = azurerm_stream_analytics_job.crypto_high_alert_job.resource_group_name
  eventhub_consumer_group_name = azurerm_eventhub_consumer_group.stream_analytics_consumer.name
  eventhub_name                = azurerm_eventhub.eh.name
  servicebus_namespace         = azurerm_eventhub_namespace.ehns.name
  shared_access_policy_key     = azurerm_eventhub_namespace.ehns.default_primary_key
  shared_access_policy_name    = "RootManageSharedAccessKey"

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}

resource "azurerm_stream_analytics_reference_input_mssql" "crypto_alert_rules" {
  name                      = "crypto-alert-rules"
  resource_group_name       = azurerm_stream_analytics_job.crypto_high_alert_job.resource_group_name
  stream_analytics_job_name = azurerm_stream_analytics_job.crypto_high_alert_job.name
  server                    = azurerm_sql_server.sql.fully_qualified_domain_name
  database                  = azurerm_sql_database.db.name
  username                  = azurerm_sql_server.sql.administrator_login
  password                  = azurerm_sql_server.sql.administrator_login_password
  refresh_type              = "RefreshPeriodicallyWithFull"
  refresh_interval_duration = "00:20:00"
  full_snapshot_query       = <<QUERY
    SELECT [UserId],[Symbol],[High],[Low]
    INTO [crypto-alert-rules]
    FROM [dbo].[CryptoAlerts]
    WHERE [IsActive] = 1
QUERY
}

data "azurerm_function_app_host_keys" "api_key" {
  name                = azurerm_function_app.fn.name
  resource_group_name = data.azurerm_resource_group.rg.name

  depends_on = [
    azurerm_function_app.fn
  ]
}

resource "azurerm_stream_analytics_output_function" "crypto_price_alert_output" {
  name                      = "crypto-price-alert-output"
  resource_group_name       = azurerm_stream_analytics_job.crypto_high_alert_job.resource_group_name
  stream_analytics_job_name = azurerm_stream_analytics_job.crypto_high_alert_job.name
  function_app              = azurerm_function_app.fn.name
  function_name             = "CryptoPriceAlert"
  api_key                   = data.azurerm_function_app_host_keys.api_key.default_function_key
}