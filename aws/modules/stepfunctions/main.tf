resource "aws_sfn_state_machine" "enjoy_ecs_run_task" {
  definition = jsonencode({
    StartAt : "RunECSTask",
    States : {
      RunECSTask : {
        Type : "Task",
        Resource : "arn:aws:states:::ecs:runTask.sync",
        Parameters : {
          Cluster : var.cluster_arn,
          TaskDefinition : var.task_definition_arn
          LaunchType : "FARGATE",
          NetworkConfiguration : {
            AwsvpcConfiguration : {
              SecurityGroups : [var.security_group_id],
              Subnets : [var.subnet_id]
            }
          },
          Overrides : {
            # 環境変数を渡すように変更すること
            ContainerOverrides : [
              {
                "Environment" : [
                  {
                    "Name" : "START_PAGE",
                    "Value.$" : "$.s1"
                  },
                  {
                    "Name" : "END_PAGE",
                    "Value.$" : "$.e1"
                  }
                ],
                "Name" : "app"
              }
            ],
          }
        },
        End : true
      }
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
