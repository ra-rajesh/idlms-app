env_name = "{{env.name}}"
region   = "{{aws.region}}"
# tf_bucket  = "stage-btl-platform-main-repo-backend-tfstate-592776312448"
# lock_table = "platform-main-state-lock"
app_port   = 4000
route_name = "{{app.name}}"

# IMPORTANT: this must match the real API name created by platform-main
rest_api_name = "{{env.name}}-apigateway"
