provider "aws" {
  region = "us-east-1"
  # LocalStack credentials
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # LocalStack endpoints
  endpoints {
    cloudwatch = "http://localhost:4566"
    ec2        = "http://localhost:4566"
  }

}

