output "url" {
  value = var.terraboard_port == 80 ? "http://${aws_lb.main.dns_name}" : "http://${aws_lb.main.dns_name}:${var.terraboard_port}"
}

output "lb_arn" {
  value = aws_lb.main.arn
}

output "lb_dns_name" {
  value = aws_lb.main.dns_name
}

output "lb_zone_id" {
  value = aws_lb.main.zone_id
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_arn" {
  value = aws_ecs_service.main.id
}

output "ecs_service_name" {
  value = aws_ecs_service.main.name
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.main.arn
}

output "ecs_task_definition_family" {
  value = aws_ecs_task_definition.main.family
}

output "ecs_task_definition_revision" {
  value = aws_ecs_task_definition.main.revision
}

output "terraboard_log_group_arn" {
  value = aws_cloudwatch_log_group.terraboard.arn
}

output "terraboard_log_group_name" {
  value = aws_cloudwatch_log_group.terraboard.name
}

output "postgres_log_group_arn" {
  value = aws_cloudwatch_log_group.postgres.arn
}

output "postgres_log_group_name" {
  value = aws_cloudwatch_log_group.postgres.name
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution.arn
}

output "ecs_execution_role_name" {
  value = aws_iam_role.ecs_execution.name
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task.arn
}

output "ecs_task_role_name" {
  value = aws_iam_role.ecs_task.name
}

output "lb_security_group_arn" {
  value = aws_security_group.lb.arn
}

output "lb_security_group_id" {
  value = aws_security_group.lb.id
}

output "lb_security_group_name" {
  value = aws_security_group.lb.name
}

output "ecs_task_security_group_arn" {
  value = aws_security_group.ecs_task.arn
}

output "ecs_task_security_group_id" {
  value = aws_security_group.ecs_task.id
}

output "ecs_task_security_group_name" {
  value = aws_security_group.ecs_task.name
}
