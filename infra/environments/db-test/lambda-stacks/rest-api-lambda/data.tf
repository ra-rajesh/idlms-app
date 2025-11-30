data "aws_api_gateway_rest_api" "shared" {
  name = var.api_name
}

data "terraform_remote_state" "lambda" {
  backend = "s3"
  config = {
    bucket = var.lambda_state_bucket
    key    = var.lambda_state_key
    region = var.region
  }
}
