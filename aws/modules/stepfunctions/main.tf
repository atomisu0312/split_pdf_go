locals {
  // ECSタスクそのものを別個のパラメータとして定義
  ecs_task_parameters = {
    Cluster        = var.cluster_arn
    TaskDefinition = var.task_definition_arn
    LaunchType     = "FARGATE"
    NetworkConfiguration = {
      AwsvpcConfiguration = {
        SecurityGroups = [var.security_group_id]
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
              "Value.$" = "$.start"
            },
            {
              "Name"    = "END_PAGE"
              "Value.$" = "$.end"
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
}

resource "aws_sfn_state_machine" "enjoy_ecs_run_task" {
  definition = jsonencode({
    StartAt : "Pass",
    States : {
      Pass : {
        "Comment" : "開始ステップ",
        "Type" : "Pass",
        "Next" : "Parallel_State",
      },
      Parallel_State : {
        "Comment" : "A Parallel state can be used to create parallel branches of execution in your state machine.",
        "Type" : "Parallel",
        "Next" : "endPass",
        "Branches" : [
          {
            StartAt : "TransformInput",
            States : {
              TransformInput : {
                Type = "Pass",
                Parameters = {
                  "start.$" = "$.s1",
                  "end.$"   = "$.e1"
                },
                Next = "RunECSTask"
              },
              RunECSTask : local.ecs_task
            }
          },
          {
            StartAt : "TransformInput2",
            States : {
              TransformInput2 : {
                Type = "Pass",
                Parameters = {
                  "start.$" = "$.s2",
                  "end.$"   = "$.e2"
                },
                Next = "RunECSTask2"
              },
              RunECSTask2 : local.ecs_task
            }
          }
        ]
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
