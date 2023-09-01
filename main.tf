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
