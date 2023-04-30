provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_policy" "custom_policy" {
  name        = "CustomPolicy"
  description = "Custom policy with specific permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "VisualEditor0"
        Effect   = "Allow"
        Action   = ["s3:*", "lambda:*", "ec2:*", "ecr:*", "sts:GetCallerIdentity"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name               = "LambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_custom_policy" {
  policy_arn = aws_iam_policy.custom_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket = "logs-bucket-${random_string.random_id.result}"
}

resource "aws_s3_bucket" "uploads_bucket" {
  bucket = "uploads-bucket-${random_string.random_id.result}"
}

resource "aws_iam_access_key" "generated_key" {
  user = aws_iam_user.shadowclone.name
}

resource "aws_iam_user" "shadowclone" {
  name = "shadowclone"
}

resource "random_string" "random_id" {
  length  = 8
  special = false
  upper   = false
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "access_key_info" {
  value = {
    "access_key_id"     = aws_iam_access_key.generated_key.id
    "secret_access_key" = aws_iam_access_key.generated_key.secret
  }
  sensitive = true
}

output "logs_bucket_name" {
  value = aws_s3_bucket.logs_bucket.bucket
}

output "uploads_bucket_name" {
  value = aws_s3_bucket.uploads_bucket.bucket
}
