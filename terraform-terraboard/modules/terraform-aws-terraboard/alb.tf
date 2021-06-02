resource "aws_lb" "main" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  subnets            = var.lb_subnets
  security_groups    = [aws_security_group.lb.id]
  tags               = merge(var.tags, { Name = var.name })
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.id
  port              = var.terraboard_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.id
  }
}

resource "aws_lb_target_group" "main" {
  name        = "ecs-terraboard"
  port        = var.terraboard_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30
  slow_start           = 0

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}
