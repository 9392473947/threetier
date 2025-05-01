resource "aws_lb" "alb" {
  count               = var.alb_count
  name                = "${var.name}-${count.index}"
  internal            = var.internal
  load_balancer_type  = "application"
  security_groups     = [var.security_group_id]
  subnets             = var.subnets
  enable_deletion_protection = var.enable_deletion_protection

  tags = var.tags
}

resource "aws_lb_target_group" "target_group" {
  count    = var.alb_count
  name     = "${var.name}-tg-${count.index}"
  port     = var.target_group_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = var.tags
}

resource "aws_lb_listener" "http" {
  count             = var.alb_count
  load_balancer_arn = aws_lb.alb[count.index].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[count.index].arn
  }
}
