using System;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using CoinAPI.REST.V1;
using Newtonsoft.Json;
using System.Net;
using System.Net.Http;

namespace DataModel.Demo
{
    public static class CryptoPriceAlert
    {
        [FunctionName("CryptoPriceAlert")]
        public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, 
                                                          ILogger log)
        {
            string content = await req.Content.ReadAsStringAsync();

            log.LogInformation("C# HTTP trigger function processed a request: " + content);
            
            return req.CreateResponse(HttpStatusCode.OK, "Executed");
        }
    }
}
