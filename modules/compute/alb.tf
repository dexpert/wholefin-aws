
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.public_subnets

  tags = {
    Name = "alb"
    Environment = "Dev"
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}
