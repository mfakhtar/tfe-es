resource "aws_launch_configuration" "fawaz-tfe-es" {
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.fawaz-tfe-es-sg.id]
  user_data       = <<-EOF
    #!/usr/bin/bash
    echo "Hello World from Fawaz" > index.html
    nohup busybox httpd -f -p 80 &
  EOF

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "fawaz-tfe-es-asg" {
  launch_configuration = aws_launch_configuration.fawaz-tfe-es.name
  vpc_zone_identifier  = local.public_subnets

  target_group_arns = [aws_lb_target_group.asg-target.arn]
  health_check_type = "ELB"

  min_size = var.asg_min
  max_size = var.asg_max

  tag {
    key                 = "Name"
    value               = "fawaz-terraform-eg-asg"
    propagate_at_launch = true
  }

}

resource "aws_lb" "fawaz-asg-lb" {
  name               = "fawaz-asg-lb"
  load_balancer_type = "application"
  subnets            = local.public_subnets
  security_groups    = [aws_security_group.fawaz-tfe-es-sg.id]
}

resource "aws_lb_listener" "fawaz-asg-lb-listner" {
  load_balancer_arn = aws_lb.fawaz-asg-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "asg-target" {
  name     = "asg-target"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.fawaz-tfe-es-vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

}

resource "aws_lb_listener_rule" "lb-asg-listner-rule" {
  listener_arn = aws_lb_listener.fawaz-asg-lb-listner.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg-target.arn
  }

}

