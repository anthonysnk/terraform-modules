## ECR repo access policy
data "aws_iam_policy_document" "allow_ecr_access_policy" {
  version = "2012-10-17"

  statement {
    sid    = "AllowImagePullAndPush"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.allowed_account_ids
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
    ]
  }
}
