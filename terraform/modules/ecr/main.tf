resource "aws_ecr_repository" "repository" {
  for_each = toset(var.repositories)
  
  name                 = each.key
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  # Lifecycle policy to keep only the latest 10 images
  # This helps control costs and keep the repository clean
  lifecycle_policy {
    policy = jsonencode({
      rules = [
        {
          rulePriority = 1,
          description  = "Keep last 10 images",
          selection = {
            tagStatus     = "any",
            countType     = "imageCountMoreThan",
            countNumber   = 10
          },
          action = {
            type = "expire"
          }
        }
      ]
    })
  }
}