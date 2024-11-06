resource "aws_ecs_cluster" "split_pdf_cluster" {
  name = "split-pdf-go"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
