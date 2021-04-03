resource "aws_iam_role" "ecs_execution" {
  name               = "${var.name}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution.json
  tags               = merge(var.tags, { Name = "${var.name}-ecs-execution" })
}

data "aws_iam_policy_document" "ecs_execution" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name               = "${var.name}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task.json
  tags               = merge(var.tags, { Name = "${var.name}-ecs-execution" })
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "efs_access" {
  name   = "efs-access"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.efs_access.json
}

data "aws_iam_policy_document" "efs_access" {
  statement {
    actions   = ["elasticfilesystem:Client*"]
    resources = [aws_efs_file_system.main.arn]

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "elasticfilesystem:AccessPointArn"
      values   = [aws_efs_access_point.postgresql_data.arn]
    }
  }
}

resource "aws_iam_role_policy" "terraboard_assume_role" {
  name   = "terraboard-assume-role"
  role   = aws_iam_role.ecs_task.id
  policy = data.aws_iam_policy_document.terraboard_assume_role.json
}

data "aws_iam_policy_document" "terraboard_assume_role" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [var.assume_role_arn]
  }
}
