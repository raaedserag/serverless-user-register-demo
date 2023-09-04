resource "aws_api_gateway_resource" "users" {
  rest_api_id = var.rest_api_id
  parent_id   = var.rest_api_root_resource_id
  path_part   = "users"
}
resource "aws_api_gateway_method" "post-users" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_integration" "post-users" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.post-users.http_method
  integration_http_method = aws_api_gateway_method.post-users.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.user_registration_lambda.invoke_arn
  credentials             = var.api_gateway_invocation_role_arn
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_registration_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.rest_api_execution_arn}/*/${aws_api_gateway_method.post-users.http_method}/users"
}
