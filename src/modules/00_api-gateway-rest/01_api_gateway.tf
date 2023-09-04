resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.namespace}-api"
  description = "This is the API for the ${var.namespace} namespace"
}

resource "aws_iam_role" "api_gateway_invocation_role" {
  name = "${var.namespace}-ag-invocation-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.namespace}-ag-invocation-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "lambda:InvokeFunction"
          Effect = "Allow"
          Resource = [
            "*"
          ]
        }
      ]
    })
  }
}

resource "aws_api_gateway_authorizer" "jwt_authorizer" {
  name                   = "jwt_authorizer"
  rest_api_id            = aws_api_gateway_rest_api.this.id
  authorizer_uri         = aws_lambda_function.authorization_lambda.invoke_arn
  authorizer_credentials = aws_iam_role.api_gateway_invocation_role.arn
  identity_source        = "method.request.header.${var.authorization_header}"
}

