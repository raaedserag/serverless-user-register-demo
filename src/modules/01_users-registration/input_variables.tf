variable "namespace" {
  type        = string
  description = "Namespace"
}
variable "rest_api_id" {
  type        = string
  description = "The REST API id"
}
variable "rest_api_root_resource_id" {
  type        = string
  description = "The REST API root resource id"
}
variable "rest_api_execution_arn" {
  type        = string
  description = "The REST API execution ARN"
}
variable "authorizer_id" {
  type        = string
  description = "The authorizer id"
}
variable "api_gateway_invocation_role_arn" {
  type        = string
  description = "The API Gateway invocation role ARN"
}
