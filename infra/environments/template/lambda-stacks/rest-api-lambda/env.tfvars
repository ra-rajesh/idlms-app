env_name = "{{env.name}}"
region   = "{{aws.region}}"

# platform_main_state_bucket = "db-test-btl-platform-main-repo-backend-tfstate-592776312448"
platform_main_state_key = "{{env.name}}/platform-main/rest-api/terraform.tfstate"

# lambda_state_bucket = "db-test-btl-platform-main-repo-backend-tfstate-592776312448"
lambda_state_key = "{{env.name}}/{{app.name}}-lambda/lambda/terraform.tfstate"

api_name   = "{{env.name}}-apigateway"
stage_name = "{{env.name}}"
