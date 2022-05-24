using Amazon;
using Amazon.Runtime;
using Amazon.SecurityToken;
using Amazon.SecurityToken.Model;
using Amazon.SimpleEmail;
using Amazon.SimpleEmail.Model;
using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;

namespace ConsoleApp
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("Hello World!");
            using (var client = new AmazonSecurityTokenServiceClient())
            {
                var response1 = await client.GetCallerIdentityAsync(new GetCallerIdentityRequest());
                Console.WriteLine(response1.Account);
                var response = await client.AssumeRoleAsync(new AssumeRoleRequest { RoleArn = "arn:aws:iam::367234352884:role/iam_role", RoleSessionName = "Session1" });
                var credentials = response.Credentials;


                using (var sesclient = new AmazonSimpleEmailServiceClient(credentials))
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
                    Console.WriteLine(sesresponse.MessageId);
                }
            }
        }
    }

    public class AlertModel
    {
        public string Name { get; set; }
        public string FavoriteAnimal { get; set; }
    }
}
