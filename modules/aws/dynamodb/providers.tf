provider "aws" {
  alias  = "secondary_region"
  region = var.secondary_region
}

