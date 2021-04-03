resource "aws_efs_file_system" "main" {
  creation_token = "terraboard-data"
  tags           = merge(var.tags, { Name = var.name })
}

resource "aws_efs_mount_target" "main" {
  count = length(var.efs_subnets)

  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.efs_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "postgresql_data" {
  file_system_id = aws_efs_file_system.main.id
  tags           = merge(var.tags, { Name = "${var.name}-postgresql-data" })

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/postgresql/data"

    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "777"
    }
  }
}

resource "aws_efs_file_system_policy" "main" {
  file_system_id = aws_efs_file_system.main.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : aws_iam_role.ecs_task.arn
        },
        "Action" : "elasticfilesystem:Client*",
        "Resource" : aws_efs_file_system.main.arn,
        "Condition" : {
          "StringEquals" : {
            "elasticfilesystem:AccessPointArn" : aws_efs_access_point.postgresql_data.arn
          }
        }
      }
    ]
  })
}
