resource "aws_ecr_repository" "repository" {
  for_each = toset(var.repositories)
  
  name                 = each.key
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Add this as a separate resource
resource "aws_ecr_lifecycle_policy" "policy" {
  for_each = toset(var.repositories)
  
  repository = aws_ecr_repository.repository[each.key].name
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