data "local_file" "stepfunctions_definition" {
  filename = "${path.module}/stepfunctions_definition.json"
}

data "aws_subnet" "default_private_subnet_a" {
  filter {
    name   = "tag:Name"
    values = ["default-private-a"]
  }
}

resource "aws_sfn_state_machine" "fargate_task" {
  name     = "MyStateMachine"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = templatefile(data.local_file.stepfunctions_definition.filename, {
    ecs_cluster_arn         = aws_ecs_cluster.fargate_cluster.arn,
    ecs_task_definition_arn = aws_ecs_task_definition.fargate_task.arn,
    subnetAz                = data.aws_subnet.default_private_subnet_a.id
    sns_arn                 = aws_sns_topic.stepfunctions_notifications.arn
  })
}

resource "aws_iam_role" "step_functions_role" {
  name = "step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "step_functions_policy" {
  name        = "stepFunctionsPolicy"
  description = "Policy for Step Functions to manage Fargate tasks and send SNS notifications"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks",
          "sns:Publish",
          "states:DescribeStateMachine",
          "states:StartExecution",
          "events:PutRule",
          "events:PutTargets",
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_functions_role_attachment" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.step_functions_policy.arn
}