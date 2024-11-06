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
  task_role_arn      = aws_iam_role.ecs_role.arn
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
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

# タスク起動用IAMロールの定義
resource "aws_iam_role" "ecs_execution_role" {
  name = "task-execution-role-for-split-pdf-go"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "task-execution-role-for-split-pdf-go"
  }
}

# タスク起動用IAMロールへのポリシー割り当て
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_execution2" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_iam_role" "ecs_role" {
  name = "task-role-for-split-pdf-go"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "task-role-for-split-pdf-go"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_role" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.ecs_role.name
}
resource "aws_iam_role_policy_attachment" "ecs_role1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.ecs_role.name
}
