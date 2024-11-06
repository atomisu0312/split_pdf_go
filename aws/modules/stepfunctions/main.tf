locals {
  // ECSタスクそのものを別個のパラメータとして定義
  ecs_task_parameters = {
    Cluster        = var.cluster_arn
    TaskDefinition = var.task_definition_arn
    LaunchType     = "FARGATE"
    NetworkConfiguration = {
      AwsvpcConfiguration = {
        AssignPublicIp = "ENABLED"
        SecurityGroups = [aws_security_group.ecs_container_sg.id]
        Subnets        = [var.subnet_id]
      }
    }
    Overrides = {
      ContainerOverrides = [
        {
          Name = "app"
          Environment = [
            {
              "Name"    = "START_PAGE"
              "Value.$" = "States.Format('{}',$.start)"
            },
            {
              "Name"    = "END_PAGE"
              "Value.$" = "States.Format('{}',$.end)"
            },
            {
              "Name"    = "FILE_NAME"
              "Value.$" = "$.file_name"
            },
            {
              "Name"    = "BUCKET_NAME"
              "Value.$" = "$.bucket_name"
            }
          ]
        }
      ]
    }
  }

  ecs_task = {
    Type : "Task",
    Resource : "arn:aws:states:::ecs:runTask.sync",
    Parameters : local.ecs_task_parameters,
    End : true
  }

  # ブランチを生成
  branches = [for num in range(var.num_machine) : {
    StartAt = "CheckLengthChoice${num}"
    States = {
      # 開始・終了ページのリスト長を元に、実行するかどうかを判断
      "CheckLengthChoice${num}" : {
        "Type" : "Choice",
        "Choices" : [
          {
            "Or" : [
              {
                "Variable" : "$.start_length",
                "NumericLessThanEquals" : "${num}"
              },
              {
                "Variable" : "$.end_length",
                "NumericLessThanEquals" : "${num}"
              }
            ],
            "Next" : "NonExectuion${num}"
          }
        ],
        "Default" : "TransformInput${num}"
      },
      # 開始・終了ページを取得
      "TransformInput${num}" = {
        Type = "Pass"
        Parameters = {
          "start.$"       = "States.ArrayGetItem($.start_pages, ${num})"
          "end.$"         = "States.ArrayGetItem($.end_pages, ${num})"
          "file_name.$"   = "$.file_name"
          "bucket_name.$" = "$.bucket_name"
        }
        Next = "ValidationInput${num}"
      },
      # 開始・終了ページの順序が正しいかどうか、そして数字として解釈できるかどうかをチェック
      "ValidationInput${num}" : {
        "Type" : "Choice",
        "Choices" : [
          {
            "Variable" : "$.start",
            "NumericLessThanEqualsPath" : "$.end",
            "Next" : "RunECSTask${num}"
          }
        ],
        "Default" : "NonExectuion${num}"
      }
      "RunECSTask${num}" = local.ecs_task,
      "NonExectuion${num}" : {
        "Type" : "Pass",
        "End" : true
      },
    }
  }]
}

resource "aws_sfn_state_machine" "enjoy_ecs_run_task" {
  definition = jsonencode({
    StartAt : "startPass",
    States : {
      startPass : {
        "Comment" : "開始ステップ",
        "Type" : "Pass",
        "Next" : "Parallel_State",
        Parameters : {
          "start_length.$" : "States.ArrayLength($.start_pages)",
          "end_length.$" : "States.ArrayLength($.end_pages)",
          "start_pages.$" : "$.start_pages",
          "end_pages.$" : "$.end_pages",
          "bucket_name.$" : "$.bucket_name",
          "file_name.$" : "$.file_name",
        }

      },
      Parallel_State : {
        "Comment" : "A Parallel state can be used to create parallel branches of execution in your state machine.",
        "Type" : "Parallel",
        "Next" : "endPass",
        "Branches" : local.branches
      },
      endPass : {
        "Comment" : "終了ステップ",
        "Type" : "Pass",
        End : true
      },
    }
  })
  role_arn = aws_iam_role.enjoy_ecs_task_run.arn
  name     = "enjoy-ecs-task-run"
  type     = "STANDARD"
}

data "aws_iam_policy_document" "assume_role_step_functions" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "enjoy_ecs_task_run" {
  name               = "enjoy-ecs-task-run-state-machine-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_step_functions.json
}

resource "aws_iam_role_policy_attachment" "enjoy_ecs_task_run" {
  role       = aws_iam_role.enjoy_ecs_task_run.name
  policy_arn = aws_iam_policy.enjoy_ecs_task_run.arn
}

resource "aws_iam_policy" "enjoy_ecs_task_run" {
  name = "enjoy-ecs-task-run-state-machine-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeClusters"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "events:PutTargets",
          "events:PutRule",
          "events:DescribeRule"
        ]
        Resource = "arn:aws:events:${var.region}:${var.account_id}:rule/StepFunctionsGetEventsForECSTaskRule"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
        ]
        Resource = [var.task_role_arn, var.task_execution_role_arn]
      }
    ]
  })
}

resource "aws_security_group" "ecs_container_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
