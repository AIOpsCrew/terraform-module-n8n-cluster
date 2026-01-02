# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection       = true
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-alb"
      Environment = var.environment
    }
  )
}

# Target Group
resource "aws_lb_target_group" "n8n" {
  name                 = "${var.project_name}-${var.environment}-tg"
  port                 = 5678
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-tg"
      Environment = var.environment
    }
  )
}

# HTTP Listener - Always redirect to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-http-listener"
  }
}

# HTTPS Listener - Always enabled with either custom or self-signed certificate
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  # Certificate priority:
  # 1. User-provided certificate ARN
  # 2. Auto-generated ACM certificate (custom domain)
  # 3. Self-signed certificate (no custom domain)
  certificate_arn = var.enable_custom_domain ? (
    var.certificate_arn != "" ? var.certificate_arn : aws_acm_certificate.main[0].arn
  ) : aws_acm_certificate.self_signed[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.n8n.arn
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-https-listener"
  }

  depends_on = [
    aws_acm_certificate_validation.main,
    aws_acm_certificate.self_signed
  ]
}
