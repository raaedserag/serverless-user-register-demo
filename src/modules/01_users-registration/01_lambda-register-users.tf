resource "aws_dynamodb_table" "users-table" {
  name           = "${var.namespace}-registered-users"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "user_registration_lambda_role" {
  name = "user-registration-lambda-role"
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
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  inline_policy {
    name = "user-registration-lambda-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "dynamodb:PutItem"
          ]
          Effect = "Allow"
          Resource = [
            aws_dynamodb_table.users-table.arn
          ]
        },
        {
          Action = [
            "lambda:InvokeFunction"
          ]
          Effect = "Allow"
          Resource = [
            "${aws_lambda_function.notify_admins_lambda.arn}"
          ]
        }
      ]
    })
  }
}

data "archive_file" "user_registration_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/lambda/user-register.py"
  output_path = "package/user-registration-lambda.zip"
}

resource "aws_lambda_function" "user_registration_lambda" {
  filename         = data.archive_file.user_registration_lambda_package.output_path
  function_name    = "user-registration"
  role             = aws_iam_role.user_registration_lambda_role.arn
  handler          = "user-register.handler"
  source_code_hash = data.archive_file.user_registration_lambda_package.output_base64sha256
  runtime          = "python3.9"
  timeout          = 15
  memory_size      = 128
  environment {
    variables = {
      USERS_TABLE                 = "${aws_dynamodb_table.users-table.name}"
      NOTIFY_ADMINS_FUNCTION_NAME = "${aws_lambda_function.notify_admins_lambda.function_name}"
    }
  }
}
