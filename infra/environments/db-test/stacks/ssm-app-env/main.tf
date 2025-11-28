resource "aws_ssm_parameter" "app_env" {
  name        = var.param_name
  description = "${var.env_name} ${var.app_name} .env"
  type        = "SecureString"
  value       = var.app_env_content
  overwrite   = true

  tags = {
    Project     = "idlms-app"
    Environment = var.env_name
  }

  lifecycle {
    # keep ops-managed value intact
    ignore_changes = [value]
  }
}
