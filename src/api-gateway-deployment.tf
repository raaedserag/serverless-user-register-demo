resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    module.api_gateway_rest,
    module.user_registration_endpoints
  ]
  rest_api_id = module.api_gateway_rest.rest_api_id

  triggers = {
    redeployment = sha1(jsonencode({
      rest_api_id = module.api_gateway_rest.rest_api_id
    }))
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_stage" "production" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = module.api_gateway_rest.rest_api_id
  stage_name    = "production"
}
