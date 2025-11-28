output "app_log_group" {
  description = "CloudWatch log group for this app"
  value       = aws_cloudwatch_log_group.app.name
}
