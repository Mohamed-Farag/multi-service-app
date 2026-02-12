# The Application Load Balancer (ALB)
resource "aws_lb" "main" {
  name               = "multi-service-alb"
  internal           = false                     # False = Internet facing (Public)
  load_balancer_type = "application"             # Application Layer (HTTP/HTTPS)
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id] # Deploys across the public subnets

  tags = {
    Name = "multi-service-alb"
  }
}

# Service A - Target Group A (Port 5000)
# This acts as a "waiting room" for valid Service A containers
resource "aws_lb_target_group" "service_a" {
  name        = "service-a-tg"
  port        = 5000            # Port the container listens on
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"            # Required for Fargate (routable via IP)

  # Health Check: ALB pinging the container to see if it's alive
  health_check {
    path                = "/"
    healthy_threshold   = 2    # Number of successes to be "Healthy"
    unhealthy_threshold = 10   # Number of failures to be "Unhealthy"
  }
}

# Listener A (Port 80)
# Listens for external traffic on Port 80 and sends it to Target Group A
resource "aws_lb_listener" "service_a" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_a.arn
  }
}

# Service B - Target Group B (Port 5001)
resource "aws_lb_target_group" "service_b" {
  name        = "service-b-tg"
  port        = 5001            # Port the container listens on
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# Listener B (Port 8080)
# Listens for external traffic on Port 8080 and sends it to Target Group B
resource "aws_lb_listener" "service_b" {
  load_balancer_arn = aws_lb.main.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service_b.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name # The public URL you use in your browser
}
