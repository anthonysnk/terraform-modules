#-------------------------------
# Terraform backend lock table
#-------------------------------

module "tfstate_lock_table" {
  source = "../../modules/aws/dynamodb"

  tags = {
    Environment = "SharedServices"
  }
}
