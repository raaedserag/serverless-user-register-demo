terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.15.0"
    }
  }
  backend "s3" {}
  required_version = ">= 1.3.5"
}

provider "aws" {}

module "api_gateway_rest" {
  source               = "./modules/00_api-gateway-rest"
  namespace            = var.namespace
  jwt_key              = var.jwt_key
  authorization_header = var.authorization_header
}

module "user_registration_endpoints" {
  source                          = "./modules/01_users-registration"
  namespace                       = var.namespace
  rest_api_id                     = module.api_gateway_rest.rest_api_id
  rest_api_root_resource_id       = module.api_gateway_rest.rest_api_root_resource_id
  rest_api_execution_arn          = module.api_gateway_rest.rest_api_execution_arn
  authorizer_id                   = module.api_gateway_rest.authorizer_id
  api_gateway_invocation_role_arn = module.api_gateway_rest.api_gateway_invocation_role_arn
}

