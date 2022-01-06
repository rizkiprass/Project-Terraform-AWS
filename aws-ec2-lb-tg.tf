////////target group prod-app
resource "aws_lb_target_group" "prod-app" {
  name     = format("%s-%s-albtg-app", var.Customer, var.environment)
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    # path = "/healthy"
    protocol = "HTTP"
    healthy_threshold = 3
    unhealthy_threshold = 2
  }
  # lifecycle {
  #     create_before_destroy = true
  #   }
  
  tags = merge(local.common_tags, {
    Name = format("%s-%s-albtg-app", var.Customer, var.environment)
  })
}

//create Listener Http
resource "aws_lb_listener" "ALBListenerwebhttp" {
  load_balancer_arn = "${aws_lb.web-alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.prod-app.arn}"
    /* redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    } */
  }
}

# // Create Listener Https
# resource "aws_lb_listener" "ALBListenerwebhttps" {
#    load_balancer_arn = "${aws_lb.web-alb.arn}"
#    port              = "443"
#    protocol          = "HTTPS"
#    ssl_policy        = "ELBSecurityPolicy-2016-08"
#    certificate_arn   = "arn:aws:acm:ap-southeast-1:465117112479:certificate/5a49ef56-ee76-4e06-93d6-0a986fbd5cd7"

#    default_action {
#      type             = "forward"
#      target_group_arn = "${aws_lb_target_group.albtg-web.arn}"
#    }
#  }

//attach vectrk-jkt01
resource "aws_lb_target_group_attachment" "albtg-web-attach" {
  target_group_arn = aws_lb_target_group.prod-app.arn
  target_id        = aws_instance.prod-app.id
  port             = 80
}






///////target group dev-app
resource "aws_lb_target_group" "albtg-dev-app" {
  name     = format("%s-dev-albtg-dev-app", var.Customer)
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  # health_check {
  #   # path = "/healthy"
  #   protocol = "HTTP"
  #   healthy_threshold = 3
  #   unhealthy_threshold = 2
  # }
  # lifecycle {
  #     create_before_destroy = true
  #   }
  
  tags = merge(local.common_tags, {
    Name = format("%s-%s-albtg-dev-app", var.Customer, var.environment)
  })
}

//create Listener Http
# resource "aws_lb_listener" "ALBListenerapphttp" {
#   load_balancer_arn = "${aws_lb.web-alb.arn}"
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "forward"
#     target_group_arn = "${aws_lb_target_group.albtg-vectrkdev-jkt01.arn}"
    
#     /*redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     } */
#   }
# }

# // Create Listener Https
# resource "aws_lb_listener" "ALBListenerbehttps" {
#    load_balancer_arn = "${aws_lb.be-alb.arn}"
#    port              = "443"
#    protocol          = "HTTPS"
#    ssl_policy        = "ELBSecurityPolicy-2016-08"
#    certificate_arn   = "arn:aws:acm:ap-southeast-1:465117112479:certificate/5a49ef56-ee76-4e06-93d6-0a986fbd5cd7"

#    default_action {
#      type             = "forward"
#      target_group_arn = "${aws_lb_target_group.albtg-be.arn}"
#    }
#  }


//attach vectrkdev-jkt01
resource "aws_lb_target_group_attachment" "vectrkdev-jkt01-attach" {
  target_group_arn = aws_lb_target_group.albtg-dev-app.arn
  target_id        = aws_instance.dev-app.id
  port             = 80
}