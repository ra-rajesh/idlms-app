output "route_base" {
  value = "/${var.route_name}"
}

output "rest_api_id" {
  value = data.aws_api_gateway_rest_api.existing.id
}

output "rest_api_name" {
  value = var.rest_api_name
}
