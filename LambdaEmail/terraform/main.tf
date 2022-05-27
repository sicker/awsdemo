provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

resource "aws_iam_role" "lambdaemail_role" {
  name = "lambdaemail_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect   = "Allow"
        Principal: {
            Service: "lambda.amazonaws.com"
        },
      },
    ]
  })

  tags = merge(
    var.additional_tags,
    {
      Name = "lambdaemail_role"
    },
    )
}

output "lambdaemail_role_arn" {
  value = aws_iam_role.lambdaemail_role.arn
}


resource "aws_iam_role_policy" "ses_policy" {
  name = "ses_policy"
  role = aws_iam_role.lambdaemail_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ses:SendTemplatedEmail",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_ses_email_identity" "alert_identity" {
  email = "sicker27@hotmail.com"
}

resource "aws_ses_template" "alert_template" {
  name    = "alert_template"
  subject = "Test Email"
  html    = "<h1>Hello {{Name}},</h1><p>Your favorite animal is {{FavoriteAnimal}}.</p>"
  text    = "Hello {{Name}},\r\nYour favorite animal is {{FavoriteAnimal}}."
}


resource "aws_lambda_function" "lambda_function" {
  filename      = "../LambdaEmail.zip"
  function_name = "LambdaEmail"
  role          = aws_iam_role.lambdaemail_role.arn
  handler       = "LambdaEmail::LambdaEmail.Function::FunctionHandler"

  source_code_hash = filebase64sha256("../LambdaEmail.zip")

  runtime = "dotnetcore3.1"

  environment {
    variables = {
      foo = "bar"
    }
  }

  depends_on = [
    aws_iam_role_policy.ses_policy,
  ]
}

# terraform init 
# terraform apply --auto-approve
# terraform destroy --auto-approve
# dotnet lambda package -o LambdaEmail.zip
# dotnet lambda deploy-function
# dotnet lambda invoke-function LambdaEmail --payload Test