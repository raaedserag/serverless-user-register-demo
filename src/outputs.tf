output "production_api_gateway_url" {
  value = aws_api_gateway_stage.production.invoke_url
  description = "value of the API Gateway URL for the production stage"
}
