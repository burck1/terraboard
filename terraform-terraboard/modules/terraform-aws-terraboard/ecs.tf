resource "aws_ecs_cluster" "main" {
  name = var.name
  tags = merge(var.tags, { Name = var.name })

  setting {
    name  = "containerInsights"
    value = var.container_insights
  }
}

resource "aws_ecs_service" "main" {
  name                  = var.name
  cluster               = aws_ecs_cluster.main.id
  task_definition       = aws_ecs_task_definition.main.arn
  desired_count         = 1
  launch_type           = "FARGATE"
  tags                  = merge(var.tags, { Name = var.name })
  wait_for_steady_state = true

  network_configuration {
    security_groups  = [aws_security_group.ecs_task.id]
    subnets          = var.ecs_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.id
    container_name   = "terraboard"
    container_port   = var.terraboard_port
  }

  depends_on = [
    aws_lb_listener.main,
  ]
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.name
  task_role_arn            = aws_iam_role.ecs_task.arn
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  tags                     = merge(var.tags, { Name = var.name })

  container_definitions = jsonencode([
    local.terraboard_container,
    local.postgres_container,
  ])

  volume {
    name = local.volume_name
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution,
    aws_iam_role_policy.terraboard_assume_role,
  ]
}

locals {
  pg_user     = "gorm"
  pg_password = "edqNDbHu3fV7PCrLFn14syqI1t"
  pg_db       = "gorm"
  volume_name = "terraboard-data"

  terraboard_container = {
    "name" : "terraboard",
    "image" : var.terraboard_image,
    # "cpu" : 10,
    # "memory" : 256,
    # "memoryReservation": 128,
    "essential" : true,
    "networkMode" : "awsvpc",
    "environment" : [
      { "name" : "TERRABOARD_PORT", "value" : tostring(var.terraboard_port) },
      { "name" : "TERRABOARD_LOG_LEVEL", "value" : var.terraboard_log_level },
      { "name" : "TERRABOARD_LOG_FORMAT", "value" : var.terraboard_log_format },
      { "name" : "DB_HOST", "value" : "localhost" },
      { "name" : "DB_USER", "value" : local.pg_user },
      { "name" : "DB_PASSWORD", "value" : local.pg_password },
      { "name" : "DB_NAME", "value" : local.pg_db },
      { "name" : "DB_SSLMODE", "value" : "disable" },
      { "name" : "AWS_BUCKET", "value" : var.state_bucket },
      { "name" : "AWS_KEY_PREFIX", "value" : var.state_key_prefix },
      { "name" : "AWS_DYNAMODB_TABLE", "value" : var.state_dynamodb_table },
      { "name" : "APP_ROLE_ARN", "value" : var.assume_role_arn },
      { "name" : "AWS_EXTERNAL_ID", "value" : var.assume_role_external_id },
      { "name" : "AWS_FILE_EXTENSION", "value" : var.state_file_extension },
    ],
    "portMappings" : [
      {
        "containerPort" : var.terraboard_port,
      },
    ],
    "logConfiguration" : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : aws_cloudwatch_log_group.terraboard.name,
        "awslogs-region" : local.region,
        "awslogs-stream-prefix" : "ecs",
      },
    },
    "dependsOn" : [
      {
        "containerName" : "postgres",
        "condition" : "HEALTHY",
      },
    ],
  }

  postgres_container = {
    "name" : "postgres",
    "image" : var.postgres_image,
    # "cpu" : 10,
    # "memory" : 256,
    # "memoryReservation": 128,
    "essential" : true,
    "networkMode" : "awsvpc",
    "environment" : [
      { "name" : "POSTGRES_USER", "value" : local.pg_user },
      { "name" : "POSTGRES_PASSWORD", "value" : local.pg_password },
      { "name" : "POSTGRES_DB", "value" : local.pg_db },
    ],
    "mountPoints" : [
      {
        "sourceVolume" : local.volume_name,
        "containerPath" : "/var/lib/postgresql/data",
      },
    ],
    "startTimeout" : 120,
    "healthCheck" : {
      "command" : ["CMD-SHELL", "pg_isready -d ${local.pg_db} -U ${local.pg_user}"],
      "interval" : 10,
      "timeout" : 5,
      "retries" : 5,
      "startPeriod" : 10,
    },
    "logConfiguration" : {
      "logDriver" : "awslogs",
      "options" : {
        "awslogs-group" : aws_cloudwatch_log_group.postgres.name,
        "awslogs-region" : local.region,
        "awslogs-stream-prefix" : "ecs",
      },
    },
  }
}
