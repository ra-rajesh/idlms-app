resource "aws_lb_target_group" "app" {
  name        = "${var.env_name}-${var.app_name}-tg-${var.app_port}"
  port        = var.app_port
  protocol    = "TCP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "ec2" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = data.terraform_remote_state.compute.outputs.instance_id
  port             = var.app_port
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = data.terraform_remote_state.nlb.outputs.lb_arn
  port              = var.app_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
