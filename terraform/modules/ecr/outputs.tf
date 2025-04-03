output "repository_urls" {
  description = "URLs of the ECR repositories"
  value       = { for repo_name, repo in aws_ecr_repository.repository : repo_name => repo.repository_url }
}

output "repository_arns" {
  description = "ARNs of the ECR repositories"
  value       = { for repo_name, repo in aws_ecr_repository.repository : repo_name => repo.arn }
}