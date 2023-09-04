output "rest_api_id" {
  value       = aws_api_gateway_rest_api.this.id
  description = "The REST API id"
}
output "rest_api_root_resource_id" {
  value       = aws_api_gateway_rest_api.this.root_resource_id
  description = "The REST API root resource id"
}
output "rest_api_execution_arn" {
  value       = aws_api_gateway_rest_api.this.execution_arn
  description = "The REST API execution ARN"
}
output "authorizer_id" {
  value       = aws_api_gateway_authorizer.jwt_authorizer.id
  description = "The authorizer id"
}
output "api_gateway_invocation_role_arn" {
  value       = aws_iam_role.api_gateway_invocation_role.arn
  description = "The API Gateway invocation role ARN"
}
