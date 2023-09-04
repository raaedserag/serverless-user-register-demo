variable namespace {
  type        = string
  description = "Namespace"
}

variable jwt_key {
  type        = string
  description = "JWT secret key for signing tokens"
}

variable "authorization_header" {
  type        = string
  description = "Authorization header name"
}