provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"
}

variable "lambda_function_name" {
  default = "lambdalogging"
}

resource "aws_iam_role" "lambdalogging_role" {
  name = "${var.lambda_function_name}_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logs" {
  name        = "${var.lambda_function_name}_log_policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambdalogging_role.name
  policy_arn = aws_iam_policy.lambda_logs.arn
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "lambdalogging" {
  filename      = "../LambdaLogging.zip"
  function_name = "${var.lambda_function_name}"
  role          = aws_iam_role.lambdalogging_role.arn
  handler       = "LambdaLogging::LambdaLogging.Function::FunctionHandler"

  source_code_hash = filebase64sha256("../LambdaLogging.zip")

  runtime = "dotnetcore3.1"

  environment {
    variables = {
      foo = "bar"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.log_group,
  ]
}


# terraform init 
# terraform apply --auto-approve
# terraform destroy --auto-approve
# dotnet lambda package -o LambdaLogging.zip
# aws lambda invoke --function-name lambdalogging out --log-type Tail
# aws lambda invoke --function-name my-function out --log-type Tail --query 'LogResult' --output text |  base64 -d
# aws lambda invoke --function-name lambdalogging --invocation-type Event --cli-binary-format raw-in-base64-out --payload "\"Test\"" out
