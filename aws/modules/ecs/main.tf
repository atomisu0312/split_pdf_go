resource "aws_ecs_cluster" "split_pdf_cluster" {
  name = "split-pdf-go"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family             = "split-go-pdf"
  cpu                = 2048
  memory             = 4096
  task_role_arn      = var.task_role_arn
  execution_role_arn = var.task_execution_role_arn
  container_definitions = jsonencode([
    {
      name      = "app"
      image     = var.image_arn
      cpu       = 0
      memory    = 512
      essential = true
      environment = [
        {
          "name" : "PROD",
          "value" : "true"
        },
        {
          "name" : "START_PAGE",
          "value" : "2"
        },
        {
          "name" : "END_PAGE",
          "value" : "9"
        },
        {
          "name" : "BACKET_NAME",
          "value" : "sample-bucket"
        },
        {
          "name" : "FILE_NAME",
          "value" : "sample.pdf"
        }
      ]
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    },

  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
