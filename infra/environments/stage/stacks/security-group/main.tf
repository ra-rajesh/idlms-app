resource "aws_security_group_rule" "allow_4000" {
  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  security_group_id = data.terraform_remote_state.compute.outputs.security_group_id
  cidr_blocks       = [for s in data.aws_subnet.priv : s.cidr_block]
}
