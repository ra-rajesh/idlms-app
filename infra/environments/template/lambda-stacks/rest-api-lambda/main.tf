locals {
  rest_id    = data.aws_api_gateway_rest_api.shared.id
  parent_id  = data.aws_api_gateway_rest_api.shared.root_resource_id
  lambda_arn = data.terraform_remote_state.lambda.outputs.lambda_alias_arn
}

# ---------------- API Resources ----------------

resource "aws_api_gateway_resource" "base" {
  rest_api_id = local.rest_id
  parent_id   = local.parent_id
  path_part   = "idlms-app-lambda"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = local.rest_id
  parent_id   = aws_api_gateway_resource.base.id
  path_part   = "{proxy+}"
}

# ---------------- Methods ----------------

resource "aws_api_gateway_method" "any_base" {
  rest_api_id   = local.rest_id
  resource_id   = aws_api_gateway_resource.base.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "any_proxy" {
  rest_api_id   = local.rest_id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

# ---------------- Integrations (Lambda Proxy) ----------------

resource "aws_api_gateway_integration" "base" {
  rest_api_id             = local.rest_id
  resource_id             = aws_api_gateway_resource.base.id
  http_method             = aws_api_gateway_method.any_base.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  # IMPORTANT: APIGW -> Lambda invoke URI format
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${local.lambda_arn}/invocations"
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = local.rest_id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.any_proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"

  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${local.lambda_arn}/invocations"
}

# ---------------- Permission so APIGW can invoke Lambda ----------------

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke-${var.env_name}"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_arn
  principal     = "apigateway.amazonaws.com"

  # Scope to this API + stage (safer than global wildcard)
  source_arn = "${data.aws_api_gateway_rest_api.shared.execution_arn}/${var.stage_name}/*/*"
}

# ---------------- Deployment + Stage ----------------

# resource "aws_api_gateway_deployment" "deploy" {
#   depends_on = [
#     aws_api_gateway_integration.base,
#     aws_api_gateway_integration.proxy,
#     aws_lambda_permission.allow_apigw
#   ]

#   rest_api_id = local.rest_id
#   description = "idlms-app-lambda deployment"

#   # Force new deployment when routes/integrations change
#   triggers = {
#     redeploy = sha1(jsonencode([
#       aws_api_gateway_resource.base.id,
#       aws_api_gateway_resource.proxy.id,
#       aws_api_gateway_method.any_base.id,
#       aws_api_gateway_method.any_proxy.id,
#       aws_api_gateway_integration.base.id,
#       aws_api_gateway_integration.proxy.id
#     ]))
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_api_gateway_stage" "stage" {
#   rest_api_id   = local.rest_id
#   stage_name    = var.stage_name
#   deployment_id = aws_api_gateway_deployment.deploy.id

#   description = "idlms-app-lambda stage"
# }
