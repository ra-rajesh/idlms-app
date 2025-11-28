output "lambda_name" {
  value = aws_lambda_function.app.function_name
}

output "lambda_alias_arn" {
  value = aws_lambda_alias.live.arn
}
