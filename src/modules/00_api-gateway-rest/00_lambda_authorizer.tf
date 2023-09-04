locals {
  lambda_requirements_path = "${path.module}/lambda/requirements.txt"
}

resource "null_resource" "lambda_authorizer_dependencies" {
  triggers = {
    requirements = filesha1(local.lambda_requirements_path)
  }
  provisioner "local-exec" {
    command = <<EOT
      rm -rf package/authorizer-dependencies-layer/python
      mkdir -p package/authorizer-dependencies-layer/python
      pip install -r ${local.lambda_requirements_path} -t package/authorizer-dependencies-layer/python
    EOT
  }
}

data "archive_file" "lambda_authorizer_dependencies_package" {
  depends_on          = [null_resource.lambda_authorizer_dependencies]
  type        = "zip"
  source_dir  = "package/authorizer-dependencies-layer"
  output_path = "package/authorizer-dependencies-layer.zip"
}

resource "aws_lambda_layer_version" "lambda_authorizer_dependencies_layer" {
  filename            = data.archive_file.lambda_authorizer_dependencies_package.output_path
  layer_name          = "authorizer-dependencies"
  source_code_hash    = filebase64sha256(data.archive_file.lambda_authorizer_dependencies_package.output_path)
  compatible_runtimes = ["python3.9"]
}


resource "aws_iam_role" "authorization_lambda_role" {
  name = "authorization-lambda-role"
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
}

data "archive_file" "authorization_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/lambda/authorize.py"
  output_path = "package/authorization-lambda.zip"
}

resource "aws_lambda_function" "authorization_lambda" {
  filename         = data.archive_file.authorization_lambda_package.output_path
  function_name    = "authorization"
  role             = aws_iam_role.authorization_lambda_role.arn
  handler          = "authorize.handler"
  source_code_hash = data.archive_file.authorization_lambda_package.output_base64sha256
  runtime          = "python3.9"
  timeout          = 15
  memory_size      = 128
  layers           = ["${aws_lambda_layer_version.lambda_authorizer_dependencies_layer.arn}"]
  environment {
    variables = {
      JWT_KEY              = "${var.jwt_key}"
      AUTHORIZATION_HEADER = "${var.authorization_header}"
    }
  }
}
