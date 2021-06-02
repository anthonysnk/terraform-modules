#-------------------------------
# Terraform backend s3 bucket
#-------------------------------

module "tfstate_bucket" {
  source = "../../modules/aws/s3"

  name      = "applaudo-infra-iac-state"
  versioned = true

  tags = local.tags
}