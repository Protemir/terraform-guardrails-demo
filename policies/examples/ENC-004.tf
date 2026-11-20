# Пример для правила ENC-004: ресурсы bad_* нарушают правило, good_* — нет.

resource "aws_lb_listener" "bad_http_forward" {
  load_balancer_arn = "arn"
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "arn"
  }
}

resource "aws_lb_listener" "bad_old_tls" {
  load_balancer_arn = "arn"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
}

resource "aws_lb_listener" "good_redirect" {
  load_balancer_arn = "arn"
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
}

resource "aws_lb_listener" "good_https" {
  load_balancer_arn = "arn"
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}
