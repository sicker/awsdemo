using Amazon.Lambda.Core;
using Newtonsoft.Json;
using System;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace LambdaLogging
{
    public class Function
    {
        
        /// <summary>
        /// A simple function that takes a string and does a ToUpper
        /// </summary>
        /// <param name="input"></param>
        /// <param name="context"></param>
        /// <returns></returns>
        public string FunctionHandler(string input, ILambdaContext context)
        {
            LambdaLogger.Log("ENVIRONMENT VARIABLES: " + JsonConvert.SerializeObject(Environment.GetEnvironmentVariables()));
            LambdaLogger.Log("CONTEXT: " + JsonConvert.SerializeObject(context));
            LambdaLogger.Log("EVENT: " + JsonConvert.SerializeObject(input));
            return input?.ToUpper();
        }
    }
}
