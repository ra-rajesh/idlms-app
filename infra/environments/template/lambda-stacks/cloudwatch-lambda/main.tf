locals {
  app_log_group_name = "/${var.env_name}/platform_main/apps/${var.app_name}-lambda/logs"

  tags = merge({
    Environment    = var.env_name
    "user:Project" = "platform_main"
    "user:Env"     = var.env_name
    "user:Stack"   = "cloudwatch-app"
  }, var.tags)
}

resource "aws_cloudwatch_log_group" "app" {
  name              = local.app_log_group_name
  retention_in_days = var.retention_in_days
  tags              = local.tags

  depends_on = [
    null_resource.nuke_current_group,
    null_resource.nuke_legacy_group,
  ]

  lifecycle {
    replace_triggered_by = [
      null_resource.nuke_current_group,
      null_resource.nuke_legacy_group,
    ]
  }
}

# Delete CURRENT /.../logs first
resource "null_resource" "nuke_current_group" {
  provisioner "local-exec" {
    command = "aws logs delete-log-group --log-group-name ${local.app_log_group_name} || true"
  }
  triggers = { t = timestamp() }
}

# Delete LEGACY /.../app if present
resource "null_resource" "nuke_legacy_group" {
  provisioner "local-exec" {
    command = "aws logs delete-log-group --log-group-name /${var.env_name}/platform_main/apps/${var.app_name}/app || true"
  }
  triggers = { t = timestamp() }
}
