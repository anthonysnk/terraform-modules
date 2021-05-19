locals {
  repos               = { for repo in var.repos : repo.name => repo }
  allowed_account_ids = [for id in var.allowed_account_ids : "arn:aws:iam::${id}:root"]
}
