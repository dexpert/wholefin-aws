
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  # security_groups    = [aws_security_group.lb_sg.id]
  # subnets            = aws_subnet.public[*].id

  tags = {
    Name = "alb"
    Environment = "Dev"
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}
