provider "aws" {
  region  = "ap-southeast-1"
  profile = "default"
}


variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

resource "aws_iam_role" "alert_role" {
  name = "iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect   = "Allow"
        Principal: {
          "AWS": "arn:aws:iam::367234352884:user/sicker_admin"
        },
      },
    ]
  })

  tags = merge(
    var.additional_tags,
    {
      Name = "iam_role"
    },
    )
}

resource "aws_iam_role_policy" "ses_policy" {
  name = "ses_policy"
  role = aws_iam_role.alert_role.id

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

output "alert_role_arn" {
  value = aws_iam_role.alert_role.arn
}