using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

using Amazon.Lambda.Core;
using Amazon.SimpleEmail;
using Amazon.SimpleEmail.Model;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace LambdaEmail
{
    public class Function
    {
        
        /// <summary>
        /// A simple function that takes a string and does a ToUpper
        /// </summary>
        /// <param name="input"></param>
        /// <param name="context"></param>
        /// <returns></returns>
        public async Task<string> FunctionHandlerAsync(string input, ILambdaContext context)
        {
            using (var sesclient = new AmazonSimpleEmailServiceClient())
            {
                var sesresponse = await sesclient.SendTemplatedEmailAsync(new SendTemplatedEmailRequest
                {
                    Source = "sicker27@hotmail.com",
                    Destination = new Destination
                    {
                        ToAddresses = new List<string> { "sicker27@hotmail.com" }
                    },
                    Template = "alert_template",
                    TemplateData = JsonSerializer.Serialize(new AlertModel { Name = "Sicker", FavoriteAnimal = "Dog" })
                });
                Console.WriteLine(JsonSerializer.Serialize(sesresponse));
            }
            return input?.ToUpper();
        }

        public class AlertModel
        {
            public string Name { get; set; }
            public string FavoriteAnimal { get; set; }
        }
    }
}
