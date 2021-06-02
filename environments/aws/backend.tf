terraform {
  backend "s3" {
    region         = "us-east-1"
    bucket         = "applaudo-infra-iac-state"
    key            = "infrastructure.tfstate"
    dynamodb_table = "terraform_locks"
    encrypt        = "true"
  }
}
