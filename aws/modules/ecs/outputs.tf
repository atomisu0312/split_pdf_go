output "cluster_arn" {
  value = aws_ecs_cluster.split_pdf_cluster.arn
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.task_definition.arn
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "ecs_role_arn" {
  value = aws_iam_role.ecs_role.arn
}
