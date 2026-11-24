# --- Provider configuration ---
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls",
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local",
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "foo"
  secret_key = "bar"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}
