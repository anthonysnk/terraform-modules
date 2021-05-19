output "repos_arn" {
  description = "The arn of the ecr repo"
  value       = zipmap(values(aws_ecr_repository.repo)[*].name, values(aws_ecr_repository.repo)[*].arn)
}

output "repos_url" {
  description = "The URL of the repositories"
  value       = zipmap(values(aws_ecr_repository.repo)[*].name, values(aws_ecr_repository.repo)[*].repository_url)
}
