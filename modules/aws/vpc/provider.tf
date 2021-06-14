terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# For standalone networks and default main object configuration
provider "aws" {
  alias = "vpc"
}
