data "aws_ecr_repository" "repository" {
  name = var.repository_name
}

data "aws_ecr_image" "image" {
  repository_name = data.aws_ecr_repository.repository.name
  most_recent     = true
}
