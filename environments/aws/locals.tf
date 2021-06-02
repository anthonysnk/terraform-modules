locals {
  # Tagging variables
  tags = {
    Environment = "Prod"
  }

  # AWS ECR repos
  repos = [
    {
      name       = "terraform-appl"
      mutable    = false
      image_scan = true
    },
  ]
}
