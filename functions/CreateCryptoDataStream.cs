using System;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using CoinAPI.REST.V1;
using Newtonsoft.Json;

namespace DataModel.Demo
{
    public static class CreateCryptoDataStream
    {
        [FunctionName("CreateCryptoDataStream")]
        public static async Task Run([TimerTrigger("0 */10 * * * *")] TimerInfo myTimer,
                                     [EventHub("dest", Connection = "EventHubConnectionAppSetting")]IAsyncCollector<string> outputEvents,
                                     ILogger log)
        {
            log.LogInformation($"C# Timer trigger function CreateCryptoDataStream began executing at: {DateTime.Now}");

            try
            {
                var coinApiKey = System.Environment.GetEnvironmentVariable("CoinApiKeyAppSetting", EnvironmentVariableTarget.Process);

                var coinApiEndpointTester = new CoinApiRestEndpointsTester(coinApiKey)
                {
                    Log = s => log.LogInformation(s)
                };

                log.LogInformation("Calling the CoinAPI List Asset method");

                var assets = await coinApiEndpointTester.Metadata_list_assetsAsync();

                log.LogInformation($"The number of Assets returned: {assets.Data.Count} ");

                int i = 0;

                foreach (var asset in assets.Data.Where(x=> x.type_is_crypto && x.price_usd.HasValue))
                {
                    var streamEvent = new CrytoAssetStreamEvent(asset);

                    string json = JsonConvert.SerializeObject(streamEvent);

                    log.LogDebug($"Sending event: {json}");

                    await outputEvents.AddAsync(json);

                    i++;
                }

                log.LogInformation($"The number of Assets streamed: {assets.Data.Count} ");
            }
            catch (Exception ex)
            { 
                log.LogError(ex, $"The following error message was produced during execution of function CreateCryptoDataStream: {ex.Message}");

                throw ex;
            }

            log.LogInformation($"C# Timer trigger function CreateCryptoDataStream finished executing at: {DateTime.Now}");
        }
    }

    public class CrytoAssetStreamEvent
    {
        public string Symbol { get; set; }
        public decimal? Price { get; set; }
        public string Name { get; set; }
        public decimal? VolumeLastHourUSD { get; set; }
        public long? SymbolsCount { get; set; }
        public long? TradeCount { get; set; }
        public long? QuoteCount { get; set; }

        public DateTime PriceTimeStamp { get => DateTime.UtcNow; }

        public CrytoAssetStreamEvent(Asset asset)
        {
            Symbol = asset.asset_id;
            Price = asset.price_usd;
            Name = asset.name;
            VolumeLastHourUSD = asset.volume_1hrs_usd;
            SymbolsCount = asset.data_symbols_count;
            TradeCount = asset.data_trade_count;
            QuoteCount = asset.data_quote_count;
        }
    }
}
