resource "aws_security_group" "lb" {
  name   = "${var.name}-load-balancer"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.name}-load-balancer" })

  ingress {
    protocol    = "tcp"
    from_port   = var.terraboard_port
    to_port     = var.terraboard_port
    cidr_blocks = var.lb_ingress_cidr_blocks
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_task" {
  name   = "${var.name}-ecs-task"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.name}-ecs-task" })

  ingress {
    protocol        = "tcp"
    from_port       = var.terraboard_port
    to_port         = var.terraboard_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "efs" {
  name   = "${var.name}-efs"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.name}-efs" })

  ingress {
    protocol        = "tcp"
    from_port       = 2049
    to_port         = 2049
    security_groups = [aws_security_group.ecs_task.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
