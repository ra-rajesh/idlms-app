# /idlms-app
resource "aws_api_gateway_resource" "app" {
  rest_api_id = data.aws_api_gateway_rest_api.existing.id
  parent_id   = data.aws_api_gateway_rest_api.existing.root_resource_id
  path_part   = var.route_name
}

# /idlms-app/{proxy+}
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = data.aws_api_gateway_rest_api.existing.id
  parent_id   = aws_api_gateway_resource.app.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "app_any" {
  rest_api_id   = data.aws_api_gateway_rest_api.existing.id
  resource_id   = aws_api_gateway_resource.app.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = data.aws_api_gateway_rest_api.existing.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# HTTP_PROXY → NLB:4000 via VPC Link from platform-main
resource "aws_api_gateway_integration" "app_integ" {
  rest_api_id             = data.aws_api_gateway_rest_api.existing.id
  resource_id             = aws_api_gateway_resource.app.id
  http_method             = aws_api_gateway_method.app_any.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = data.terraform_remote_state.restapi.outputs.vpc_link_id
  uri                     = "http://${data.terraform_remote_state.nlb.outputs.lb_dns_name}:${var.app_port}"
}

resource "aws_api_gateway_integration" "proxy_integ" {
  rest_api_id             = data.aws_api_gateway_rest_api.existing.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_any.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = data.terraform_remote_state.restapi.outputs.vpc_link_id
  uri                     = "http://${data.terraform_remote_state.nlb.outputs.lb_dns_name}:${var.app_port}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}
