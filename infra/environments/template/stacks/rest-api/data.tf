# NLB state (to get lb_dns_name)
data "terraform_remote_state" "nlb" {
  backend = "s3"
  config = {
    bucket         = var.tf_bucket
    key            = "${var.env_name}/platform-main/nlb/terraform.tfstate"
    region         = var.region
    dynamodb_table = var.lock_table
  }
}

# REST API lookup by NAME (this is the key change!)
data "aws_api_gateway_rest_api" "existing" {
  name = var.rest_api_name
}

# If you still need VPC Link id from platform-main remote state:
data "terraform_remote_state" "restapi" {
  backend = "s3"
  config = {
    bucket         = var.tf_bucket
    key            = "${var.env_name}/platform-main/rest-api/terraform.tfstate"
    region         = var.region
    dynamodb_table = var.lock_table
  }
}
