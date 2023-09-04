resource "aws_sns_topic" "user_registration_notifications" {
  name = "${var.namespace}-users-registration"
}

resource "aws_iam_role" "notify_admins_lambda_role" {
  name = "notify-admins-lambda-role"
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
    name = "notify-admins-lambda-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "sns:Publish"
          ]
          Effect = "Allow"
          Resource = [
            aws_sns_topic.user_registration_notifications.arn
          ]
        }
      ]
    })
  }
}

data "archive_file" "notify_admins_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/lambda/notify-admins.py"
  output_path = "package/notify-admins-lambda.zip"
}

resource "aws_lambda_function" "notify_admins_lambda" {
  filename         = data.archive_file.notify_admins_lambda_package.output_path
  function_name    = "notify-admins"
  role             = aws_iam_role.notify_admins_lambda_role.arn
  handler          = "notify-admins.handler"
  source_code_hash = data.archive_file.notify_admins_lambda_package.output_base64sha256
  runtime          = "python3.9"
  timeout          = 15
  memory_size      = 128
  environment {
    variables = {
      SNS_TOPIC_ARN = "${aws_sns_topic.user_registration_notifications.arn}"
    }
  }
}
