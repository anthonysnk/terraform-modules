# -------------------------------------------------------------
# ECR Module
# -------------------------------------------------------------

## ECR repo
resource "aws_ecr_repository" "repo" {
  for_each             = length(local.repos) > 0 ? local.repos : {}
  name                 = each.value.name
  image_tag_mutability = each.value.mutable ? "MUTABLE" : "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = each.value.image_scan
  }

  tags = merge(var.tags, { "role" = "repo", "Name" = each.value.name })
}

## ECR resource policy
resource "aws_ecr_repository_policy" "allow_access" {
  for_each   = length(local.repos) > 0 ? local.repos : {}
  repository = each.value.name
  policy     = var.resource_based_policy ? data.aws_iam_policy_document.allow_ecr_access_policy.json : ""
  depends_on = [aws_ecr_repository.repo]
}

